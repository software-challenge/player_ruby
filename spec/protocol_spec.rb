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
    it 'updates the game state' do
      server_message <<-XML
  <room roomId="bc65c764-c062-4b06-940c-5c6c39cb2324">
    <data class="memento">
      <state startPlayerColor="RED" currentPlayerColor="BLUE" turn="3">
        <red color="RED" displayName=""/>
        <blue color="BLUE" displayName="aBluePlayer"/>
      XML
      expect(subject.gamestate.turn).to eq(3)
      expect(subject.gamestate.start_player_color).to eq(PlayerColor::RED)
      expect(subject.gamestate.current_player_color).to eq(PlayerColor::BLUE)
      expect(subject.gamestate.current_player).to_not be_nil
      expect(subject.gamestate.red.name).to eq('')
      expect(subject.gamestate.blue.name).to eq('aBluePlayer')
    end

    xit 'updates the last move, if it exists in the gamestate' do
      server_message <<-XML
        <state turn="2" startPlayer="RED" currentPlayer="BLUE">
          <lastMove class="move" x="8" y="9" direction="DOWN"/>
      XML
      move = Move.new(8, 9, Direction::DOWN)
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
          <fields>
            <null/>
            <null/>
            <null/>
            <null/>
            <null/>
            <field x="-5" y="0" z="5" isObstructed="false"/>
            <field x="-5" y="1" z="4" isObstructed="false"/>
            <field x="-5" y="2" z="3" isObstructed="false"/>
            <field x="-5" y="3" z="2" isObstructed="false"/>
            <field x="-5" y="4" z="1" isObstructed="false"/>
            <field x="-5" y="5" z="0" isObstructed="false"/>
          </fields>
          <fields>
            <null/>
            <null/>
            <null/>
            <null/>
            <field x="-4" y="-1" z="5" isObstructed="false"/>
            <field x="-4" y="0" z="4" isObstructed="false"/>
            <field x="-4" y="1" z="3" isObstructed="false"/>
            <field x="-4" y="2" z="2" isObstructed="true"/>
            <field x="-4" y="3" z="1" isObstructed="false"/>
            <field x="-4" y="4" z="0" isObstructed="false"/>
            <field x="-4" y="5" z="-1" isObstructed="false"/>
          </fields>
          <fields>
            <null/>
            <null/>
            <null/>
            <field x="-3" y="-2" z="5" isObstructed="false"/>
            <field x="-3" y="-1" z="4" isObstructed="false"/>
            <field x="-3" y="0" z="3" isObstructed="false"/>
            <field x="-3" y="1" z="2" isObstructed="false"/>
            <field x="-3" y="2" z="1" isObstructed="false"/>
            <field x="-3" y="3" z="0" isObstructed="false"/>
            <field x="-3" y="4" z="-1" isObstructed="false"/>
            <field x="-3" y="5" z="-2" isObstructed="false"/>
          </fields>
          <fields>
            <null/>
            <null/>
            <field x="-2" y="-3" z="5" isObstructed="false"/>
            <field x="-2" y="-2" z="4" isObstructed="false"/>
            <field x="-2" y="-1" z="3" isObstructed="false"/>
            <field x="-2" y="0" z="2" isObstructed="false"/>
            <field x="-2" y="1" z="1" isObstructed="false"/>
            <field x="-2" y="2" z="0" isObstructed="false"/>
            <field x="-2" y="3" z="-1" isObstructed="false"/>
            <field x="-2" y="4" z="-2" isObstructed="false">
              <piece owner="BLUE" type="GRASSHOPPER"/>
            </field>
            <field x="-2" y="5" z="-3" isObstructed="false"/>
          </fields>
          <fields>
            <null/>
            <field x="-1" y="-4" z="5" isObstructed="false"/>
            <field x="-1" y="-3" z="4" isObstructed="false"/>
            <field x="-1" y="-2" z="3" isObstructed="false"/>
            <field x="-1" y="-1" z="2" isObstructed="false"/>
            <field x="-1" y="0" z="1" isObstructed="false"/>
            <field x="-1" y="1" z="0" isObstructed="false"/>
            <field x="-1" y="2" z="-1" isObstructed="false"/>
            <field x="-1" y="3" z="-2" isObstructed="false"/>
            <field x="-1" y="4" z="-3" isObstructed="false"/>
            <field x="-1" y="5" z="-4" isObstructed="false"/>
          </fields>
          <fields>
            <field x="0" y="-5" z="5" isObstructed="false"/>
            <field x="0" y="-4" z="4" isObstructed="false"/>
            <field x="0" y="-3" z="3" isObstructed="false"/>
            <field x="0" y="-2" z="2" isObstructed="false"/>
            <field x="0" y="-1" z="1" isObstructed="false"/>
            <field x="0" y="0" z="0" isObstructed="false">
              <piece owner="RED" type="ANT"/>
              <piece owner="BLUE" type="BEE"/>
            </field>
            <field x="0" y="1" z="-1" isObstructed="false"/>
            <field x="0" y="2" z="-2" isObstructed="false"/>
            <field x="0" y="3" z="-3" isObstructed="false"/>
            <field x="0" y="4" z="-4" isObstructed="false"/>
            <field x="0" y="5" z="-5" isObstructed="false"/>
          </fields>
          <fields>
            <field x="1" y="-5" z="4" isObstructed="false"/>
            <field x="1" y="-4" z="3" isObstructed="false"/>
            <field x="1" y="-3" z="2" isObstructed="false"/>
            <field x="1" y="-2" z="1" isObstructed="false"/>
            <field x="1" y="-1" z="0" isObstructed="false"/>
            <field x="1" y="0" z="-1" isObstructed="false"/>
            <field x="1" y="1" z="-2" isObstructed="false"/>
            <field x="1" y="2" z="-3" isObstructed="false"/>
            <field x="1" y="3" z="-4" isObstructed="false"/>
            <field x="1" y="4" z="-5" isObstructed="false"/>
            <null/>
          </fields>
          <fields>
            <field x="2" y="-5" z="3" isObstructed="false"/>
            <field x="2" y="-4" z="2" isObstructed="false"/>
            <field x="2" y="-3" z="1" isObstructed="false"/>
            <field x="2" y="-2" z="0" isObstructed="false"/>
            <field x="2" y="-1" z="-1" isObstructed="false"/>
            <field x="2" y="0" z="-2" isObstructed="false"/>
            <field x="2" y="1" z="-3" isObstructed="false"/>
            <field x="2" y="2" z="-4" isObstructed="false"/>
            <field x="2" y="3" z="-5" isObstructed="false"/>
            <null/>
            <null/>
          </fields>
          <fields>
            <field x="3" y="-5" z="2" isObstructed="false"/>
            <field x="3" y="-4" z="1" isObstructed="false"/>
            <field x="3" y="-3" z="0" isObstructed="false"/>
            <field x="3" y="-2" z="-1" isObstructed="false"/>
            <field x="3" y="-1" z="-2" isObstructed="false"/>
            <field x="3" y="0" z="-3" isObstructed="false"/>
            <field x="3" y="1" z="-4" isObstructed="false"/>
            <field x="3" y="2" z="-5" isObstructed="false"/>
            <null/>
            <null/>
            <null/>
          </fields>
          <fields>
            <field x="4" y="-5" z="1" isObstructed="false"/>
            <field x="4" y="-4" z="0" isObstructed="false"/>
            <field x="4" y="-3" z="-1" isObstructed="false"/>
            <field x="4" y="-2" z="-2" isObstructed="false"/>
            <field x="4" y="-1" z="-3" isObstructed="false"/>
            <field x="4" y="0" z="-4" isObstructed="false"/>
            <field x="4" y="1" z="-5" isObstructed="false"/>
            <null/>
            <null/>
            <null/>
            <null/>
          </fields>
          <fields>
            <field x="5" y="-5" z="0" isObstructed="false"/>
            <field x="5" y="-4" z="-1" isObstructed="false"/>
            <field x="5" y="-3" z="-2" isObstructed="false"/>
            <field x="5" y="-2" z="-3" isObstructed="false"/>
            <field x="5" y="-1" z="-4" isObstructed="false"/>
            <field x="5" y="0" z="-5" isObstructed="false"/>
            <null/>
            <null/>
            <null/>
            <null/>
            <null/>
          </fields>
        </board>
      XML
      board = subject.gamestate.board
      expect(board.field_list.size).to eq(Board::FIELD_AMOUNT)
      expect(board.field(0, 0).pieces.size).to eq(2)
      expect(board.field(0, 0).pieces).to eq([Piece.new(PlayerColor::RED, PieceType::ANT), Piece.new(PlayerColor::BLUE, PieceType::BEE)])
      expect(board.field(-2, 4).pieces).to eq([Piece.new(PlayerColor::BLUE, PieceType::GRASSHOPPER)])
      expect(board.field(-4, 2).obstructed).to be true
      board.field_list.each do |f|
        unless [[0, 0], [-2, 4], [-4, 2]].include? [f.coordinates.x, f.coordinates.y]
          expect(f).to be_empty
        end
      end
    end
  end

  it 'converts a setmove to xml' do
    move = SetMove.new(Piece.new(PlayerColor::BLUE, PieceType::ANT), CubeCoordinates.new(-2, 0))
    # NOTE that this is brittle because XML formatting (whitespace, attribute
    # order) is arbitrary.
    expect(subject.move_to_xml(move)).to eq <<~XML
      <data class="setmove">
        <piece owner="BLUE" type="ANT"/>
        <destination x="-2" y="0" z="2"/>
      </data>
    XML
  end

  it 'converts a dragmove to xml' do
    move = DragMove.new(CubeCoordinates.new(3, 1), CubeCoordinates.new(-1, -2))
    # NOTE that this is brittle because XML formatting (whitespace, attribute
    # order) is arbitrary.
    expect(subject.move_to_xml(move)).to eq <<~XML
      <data class="dragmove">
        <start x="3" y="1" z="-4"/>
        <destination x="-1" y="-2" z="3"/>
      </data>
    XML
  end

  it 'converts a skipmove to xml' do
    move = SkipMove.new
    # NOTE that this is brittle because XML formatting (whitespace, attribute
    # order) is arbitrary.
    expect(subject.move_to_xml(move)).to eq <<~XML
      <data class="skipmove">
      </data>
    XML
  end
end
