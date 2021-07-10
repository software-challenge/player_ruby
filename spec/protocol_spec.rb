# encoding: utf-8
# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Protocol do
  let(:client) { instance_double('Client') }
  let(:network) { instance_double('Network') }

  subject { Protocol.new(network, client) }

  before { allow(client).to receive(:gamestate=) }

  def server_message(xml)
    subject.process_string xml
  end

  context 'when getting a new game state' do

    before do
      server_message <<-XML
      <room roomId="e870dd98-7300-437a-a16c-1ee317dfb63e">
      <data class="memento">
        <state class="state" turn="3">
          <startTeam class="team">ONE</startTeam>
          <board>
            <pieces>
              <entry>
                <coordinates x="0" y="0"/>
                <piece type="Herzmuschel" team="ONE" count="1"/>
              </entry>
              <entry>
                <coordinates x="7" y="7"/>
                <piece type="Herzmuschel" team="TWO" count="1"/>
              </entry>
              <entry>
                <coordinates x="0" y="1"/>
                <piece type="Robbe" team="ONE" count="1"/>
              </entry>
              <entry>
                <coordinates x="0" y="2"/>
                <piece type="Robbe" team="ONE" count="1"/>
              </entry>
              <entry>
                <coordinates x="0" y="3"/>
                <piece type="Herzmuschel" team="ONE" count="1"/>
              </entry>
              <entry>
                <coordinates x="0" y="4"/>
                <piece type="Seestern" team="ONE" count="1"/>
              </entry>
              <entry>
                <coordinates x="0" y="5"/>
                <piece type="Moewe" team="ONE" count="1"/>
              </entry>
              <entry>
                <coordinates x="0" y="6"/>
                <piece type="Seestern" team="ONE" count="1"/>
              </entry>
              <entry>
                <coordinates x="0" y="7"/>
                <piece type="Moewe" team="ONE" count="1"/>
              </entry>
              <entry>
                <coordinates x="7" y="0"/>
                <piece type="Moewe" team="TWO" count="1"/>
              </entry>
              <entry>
                <coordinates x="7" y="1"/>
                <piece type="Seestern" team="TWO" count="1"/>
              </entry>
              <entry>
                <coordinates x="7" y="2"/>
                <piece type="Moewe" team="TWO" count="1"/>
              </entry>
              <entry>
                <coordinates x="7" y="3"/>
                <piece type="Seestern" team="TWO" count="1"/>
              </entry>
              <entry>
                <coordinates x="7" y="4"/>
                <piece type="Herzmuschel" team="TWO" count="1"/>
              </entry>
              <entry>
                <coordinates x="7" y="5"/>
                <piece type="Robbe" team="TWO" count="1"/>
              </entry>
              <entry>
                <coordinates x="7" y="6"/>
                <piece type="Robbe" team="TWO" count="1"/>
              </entry>
            </pieces>
          </board>
          <lastMove>
            <from x="4" y="4"/>
            <to x="5" y="6"/>
          </lastMove>
          <ambers enum-type="team">
            <entry>
              <team>ONE</team>
              <int>1</int>
            </entry>
            <entry>
              <team>TWO</team>
              <int>0</int>
            </entry>
          </ambers>
        </state>
      </data>
    </room>
      XML
    end

    it 'sets the current turn' do
      expect(subject.gamestate.turn).to eq(3)
    end

    it 'sets the last move' do
      expect(subject.gamestate.last_move.piece.type).to eq(PieceType::Seestern)
      expect(subject.gamestate.last_move.piece.color).to eq(Color::BLUE)
      expect(subject.gamestate.last_move.piece.position.x).to eq(2)
    end

    it 'converts a setmove to xml' do
      move = Move.new(Coordinates.new(4,2), Coordinates.new(4,3))
      # NOTE that this is brittle because XML formatting (whitespace, attribute
      # order) is arbitrary.
      expect(subject.move_to_xml(move)).to eq <<~XML
      <data class="sc.plugin2022.Move">
        <piece color="BLUE" type="GULL">
          <position x="4" y="2"/>
        </piece>
        <target x="4" y="3"/>
      </data>
      XML
    end
  
    it 'converts a skipmove to xml' do
      move = SkipMove.new
      # NOTE that this is brittle because XML formatting (whitespace, attribute
      # order) is arbitrary.
      expect(subject.move_to_xml(move)).to eq <<~XML
      <data class="sc.plugin2022.SkipMove">
      </data>
      XML
    end

    xit 'updates the last move' do
      move = Move.new(Piece.new(Team::TWO, PieceType::Seestern, Coordinates.new(2, 7)), Coordinates.new(2, 6))
      expect(subject.gamestate.last_move).to eq(move)
    end
  end

  xcontext 'when getting a winning condition from server' do
    it 'closes the connection' do
      expect(network).to receive(:disconnect)
      server_message '<data class="result" />'
    end
    it 'sets the winning player' do
      expect(network).to receive(:disconnect)
      server_message <<-XML
        <data class="result">
          <definition>
            <fragment name="Gewinner">
              <aggregation>SUM</aggregation>
              <relevantForRanking>true</relevantForRanking>
            </fragment>
            <fragment name="Ø Schwarm">
              <aggregation>AVERAGE</aggregation>
              <relevantForRanking>true</relevantForRanking>
            </fragment>
          </definition>
          <score cause="CAUSE1" reason="R1">
            <part>2</part>
            <part>23</part>
          </score>
          <score cause="CAUSE2" reason="R2">
            <part>0</part>
            <part>3</part>
          </score>
          <winner displayName="Winning Player" color="BLUE" />
        </data>
      XML
      expect(subject.gamestate.condition.winner.name).to eq('Winning Player')
      expect(subject.gamestate.condition.reason).to eq('R2')
    end
  end

  context 'when receiving a new board' do
    it 'creates the new board in the gamestate' do
      subject.gamestate.board.clear
      server_message <<-XML
      <board>
            <field x="0" y="0" color="RED" type="COCKLE"/>
            <field x="1" y="0" color="RED" type="SEAL"/>
            <field x="2" y="0" color="RED" type="STARFISH"/>
            <field x="3" y="0" color="RED" type="GULL"/>
            <field x="4" y="0" color="RED" type="COCKLE"/>
            <field x="5" y="0" color="RED" type="STARFISH"/>
            <field x="6" y="0" color="RED" type="SEAL"/>
            <field x="7" y="0" color="RED" type="GULL"/>
            <field x="0" y="7" color="BLUE" type="COCKLE"/>
            <field x="1" y="7" color="BLUE" type="SEAL"/>
            <field x="2" y="7" color="BLUE" type="STARFISH"/>
            <field x="3" y="7" color="BLUE" type="GULL"/>
            <field x="4" y="7" color="BLUE" type="COCKLE"/>
            <field x="5" y="7" color="BLUE" type="STARFISH"/>
            <field x="6" y="7" color="BLUE" type="SEAL"/>
            <field x="7" y="7" color="BLUE" type="GULL"/>
    </board>
      XML
      board = subject.gamestate.board
      expect(board.field(3, 0)).to eq(Field.new(3, 0, Piece.new(Team::ONE, PieceType::GULL, Coordinates.new(3, 0))))
      expect(board.field(6, 7)).to eq(Field.new(6, 7, Piece.new(Team::TWO, PieceType::Robbe, Coordinates.new(6, 7))))
      expect(board.red_pieces).not_to be_empty
    end
  end
end
