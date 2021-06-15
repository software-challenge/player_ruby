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
      <room roomId="cb3bc426-5c70-48b9-9307-943bc328b503">
      <data class="memento">
        <state class="state" turn="1" round="0">
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
          <first displayName="OwO">
            <color>RED</color>
          </first>
          <second displayName="UwU">
            <color>BLUE</color>
          </second>
          <lastMove class="sc.plugin2022.Move">
            <piece color="BLUE" type="STARFISH">
              <position x="2" y="7"/>
            </piece>
            <target x="2" y="6">
          </lastMove>
          <startColor>BLUE</startColor>
        </state>
      </data>
    </room>
      XML
    end

    it 'sets the current turn' do
      expect(subject.gamestate.turn).to eq(2)
    end

    it 'sets the start color' do
      expect(subject.gamestate.start_color).to eq(Color::BLUE)
    end

    it 'sets the current color' do
      expect(subject.gamestate.current_color_index).to eq(2)
    end

    it 'sets the player names' do
      expect(subject.gamestate.player_one.name).to eq('OwO')
      expect(subject.gamestate.player_two.name).to eq('UwU')
    end

    it 'sets the last move' do
      expect(subject.gamestate.last_move.piece.kind).to eq(PieceShape::PENTO_V)
      expect(subject.gamestate.last_move.piece.color).to eq(Color::BLUE)
      expect(subject.gamestate.last_move.piece.position.x).to eq(17)
    end

    it 'converts a setmove to xml' do
      move = SetMove.new(Piece.new(Color::BLUE, PieceShape::PENTO_T, Rotation::LEFT, false, Coordinates.new(4,2)))
      # NOTE that this is brittle because XML formatting (whitespace, attribute
      # order) is arbitrary.
      expect(subject.move_to_xml(move)).to eq <<~XML
      <data class="sc.plugin2021.SetMove">
        <piece color="BLUE" kind="PENTO_T" rotation="LEFT" isFlipped="false">
          <position x="4" y="2"/>
        </piece>
      </data>
      XML
    end
  
    it 'converts a skipmove to xml' do
      move = SkipMove.new
      # NOTE that this is brittle because XML formatting (whitespace, attribute
      # order) is arbitrary.
      expect(subject.move_to_xml(move)).to eq <<~XML
      <data class="sc.plugin2021.SkipMove">
        <color>RED</color>
      </data>
      XML
    end

    xit 'updates the last move' do
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
      <field x="0" y="0" content="BLUE"/>
      <field x="1" y="0" content="RED"/>
      <field x="2" y="0" content="RED"/>
      <field x="3" y="0" content="RED"/>
      <field x="8" y="0" content="RED"/>
      <field x="12" y="0" content="RED"/>
      <field x="13" y="0" content="RED"/>
      <field x="14" y="0" content="RED"/>
      <field x="15" y="0" content="RED"/>
      <field x="16" y="0" content="RED"/>
      <field x="19" y="0" content="RED"/>
      <field x="0" y="1" content="BLUE"/>
      <field x="1" y="1" content="BLUE"/>
      <field x="2" y="1" content="BLUE"/>
      <field x="4" y="1" content="RED"/>
      <field x="5" y="1" content="RED"/>
      <field x="6" y="1" content="RED"/>
      <field x="8" y="1" content="RED"/>
      <field x="9" y="1" content="RED"/>
      <field x="10" y="1" content="RED"/>
      <field x="11" y="1" content="RED"/>
      <field x="17" y="1" content="RED"/>
      <field x="18" y="1" content="RED"/>
      <field x="19" y="1" content="RED"/>
      <field x="1" y="2" content="BLUE"/>
      <field x="2" y="2" content="RED"/>
      <field x="3" y="2" content="BLUE"/>
      <field x="4" y="2" content="BLUE"/>
      <field x="6" y="2" content="RED"/>
      <field x="7" y="2" content="RED"/>
      <field x="18" y="2" content="RED"/>
      <field x="0" y="3" content="BLUE"/>
      <field x="1" y="3" content="RED"/>
      <field x="2" y="3" content="BLUE"/>
      <field x="3" y="3" content="RED"/>
      <field x="4" y="3" content="RED"/>
      <field x="5" y="3" content="RED"/>
      <field x="6" y="3" content="BLUE"/>
      <field x="8" y="3" content="RED"/>
      <field x="0" y="4" content="RED"/>
      <field x="1" y="4" content="RED"/>
      <field x="2" y="4" content="BLUE"/>
      <field x="4" y="4" content="RED"/>
      <field x="5" y="4" content="BLUE"/>
      <field x="6" y="4" content="BLUE"/>
      <field x="8" y="4" content="RED"/>
      <field x="0" y="5" content="BLUE"/>
      <field x="1" y="5" content="BLUE"/>
      <field x="2" y="5" content="BLUE"/>
      <field x="4" y="5" content="BLUE"/>
      <field x="5" y="5" content="BLUE"/>
      <field x="6" y="5" content="RED"/>
      <field x="7" y="5" content="RED"/>
      <field x="8" y="5" content="RED"/>
      <field x="3" y="6" content="BLUE"/>
      <field x="6" y="6" content="BLUE"/>
      <field x="0" y="7" content="BLUE"/>
      <field x="1" y="7" content="BLUE"/>
      <field x="2" y="7" content="BLUE"/>
      <field x="3" y="7" content="BLUE"/>
      <field x="5" y="7" content="BLUE"/>
      <field x="6" y="7" content="BLUE"/>
      <field x="0" y="8" content="YELLOW"/>
      <field x="1" y="8" content="YELLOW"/>
      <field x="4" y="8" content="BLUE"/>
      <field x="6" y="8" content="BLUE"/>
      <field x="0" y="9" content="GREEN"/>
      <field x="1" y="9" content="YELLOW"/>
      <field x="2" y="9" content="BLUE"/>
      <field x="3" y="9" content="BLUE"/>
      <field x="4" y="9" content="BLUE"/>
      <field x="7" y="9" content="GREEN"/>
      <field x="0" y="10" content="GREEN"/>
      <field x="1" y="10" content="YELLOW"/>
      <field x="2" y="10" content="GREEN"/>
      <field x="3" y="10" content="YELLOW"/>
      <field x="5" y="10" content="BLUE"/>
      <field x="6" y="10" content="GREEN"/>
      <field x="7" y="10" content="GREEN"/>
      <field x="0" y="11" content="GREEN"/>
      <field x="1" y="11" content="YELLOW"/>
      <field x="2" y="11" content="GREEN"/>
      <field x="3" y="11" content="YELLOW"/>
      <field x="4" y="11" content="BLUE"/>
      <field x="5" y="11" content="BLUE"/>
      <field x="7" y="11" content="GREEN"/>
      <field x="0" y="12" content="YELLOW"/>
      <field x="1" y="12" content="GREEN"/>
      <field x="2" y="12" content="YELLOW"/>
      <field x="3" y="12" content="YELLOW"/>
      <field x="7" y="12" content="GREEN"/>
      <field x="0" y="13" content="YELLOW"/>
      <field x="1" y="13" content="GREEN"/>
      <field x="2" y="13" content="GREEN"/>
      <field x="4" y="13" content="GREEN"/>
      <field x="5" y="13" content="GREEN"/>
      <field x="6" y="13" content="GREEN"/>
      <field x="0" y="14" content="YELLOW"/>
      <field x="2" y="14" content="YELLOW"/>
      <field x="3" y="14" content="GREEN"/>
      <field x="6" y="14" content="GREEN"/>
      <field x="7" y="14" content="GREEN"/>
      <field x="0" y="15" content="YELLOW"/>
      <field x="2" y="15" content="YELLOW"/>
      <field x="4" y="15" content="YELLOW"/>
      <field x="6" y="15" content="YELLOW"/>
      <field x="8" y="15" content="GREEN"/>
      <field x="9" y="15" content="GREEN"/>
      <field x="10" y="15" content="GREEN"/>
      <field x="11" y="15" content="GREEN"/>
      <field x="0" y="16" content="YELLOW"/>
      <field x="2" y="16" content="YELLOW"/>
      <field x="4" y="16" content="YELLOW"/>
      <field x="6" y="16" content="YELLOW"/>
      <field x="11" y="16" content="GREEN"/>
      <field x="1" y="17" content="YELLOW"/>
      <field x="3" y="17" content="YELLOW"/>
      <field x="4" y="17" content="YELLOW"/>
      <field x="5" y="17" content="YELLOW"/>
      <field x="7" y="17" content="YELLOW"/>
      <field x="12" y="17" content="GREEN"/>
      <field x="13" y="17" content="GREEN"/>
      <field x="14" y="17" content="GREEN"/>
      <field x="15" y="17" content="GREEN"/>
      <field x="16" y="17" content="GREEN"/>
      <field x="18" y="17" content="GREEN"/>
      <field x="1" y="18" content="YELLOW"/>
      <field x="2" y="18" content="YELLOW"/>
      <field x="6" y="18" content="YELLOW"/>
      <field x="7" y="18" content="YELLOW"/>
      <field x="17" y="18" content="GREEN"/>
      <field x="18" y="18" content="GREEN"/>
      <field x="0" y="19" content="YELLOW"/>
      <field x="1" y="19" content="YELLOW"/>
      <field x="3" y="19" content="YELLOW"/>
      <field x="5" y="19" content="YELLOW"/>
      <field x="6" y="19" content="YELLOW"/>
      <field x="18" y="19" content="GREEN"/>
      <field x="19" y="19" content="GREEN"/>
    </board>
      XML
      board = subject.gamestate.board
      expect(board.field(6, 18)).to eq(Field.new(6, 18, Color::YELLOW))
      expect(board.field(18, 18)).to eq(Field.new(18, 18, Color::GREEN))
      expect(board.fields_of_color(Color::RED)).not_to be_empty
    end
  end
end
