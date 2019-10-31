# encoding: utf-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Protocol do
  let(:client) { instance_double('Client') }
  let(:network) { instance_double('Network') }

  subject { Protocol.new(network, client) }

  before { allow(client).to receive(:gamestate=) }

  def server_message(xml)
    subject.process_string xml
  end

=begin

  context 'when getting a new game state' do
    it 'updates the game state' do
      server_message <<-XML
  <room roomId="bc65c764-c062-4b06-940c-5c6c39cb2324">
    <data class="memento">
      <state class="sc.plugin2019.GameState" startPlayerColor="RED" currentPlayerColor="BLUE" turn="2">
        <red displayName="Roter Spieler" color="RED"/>
        <blue displayName="Blauer Spieler" color="BLUE"/>
      XML
      expect(subject.gamestate.turn).to eq(2)
      expect(subject.gamestate.start_player_color).to eq(PlayerColor::RED)
      expect(subject.gamestate.current_player_color).to eq(PlayerColor::BLUE)
      expect(subject.gamestate.current_player).to_not be_nil
      expect(subject.gamestate.red.name).to eq('Roter Spieler')
      expect(subject.gamestate.blue.name).to eq('Blauer Spieler')
    end

    it 'updates the last move, if it exists in the gamestate' do
      server_message <<-XML
        <state class="state" turn="2" startPlayer="RED" currentPlayer="BLUE">
          <lastMove class="move" x="8" y="9" direction="DOWN"/>
      XML
      move = Move.new(8,9,Direction::DOWN)
      expect(subject.gamestate.last_move).to eq(move)
    end
  end

  context 'when getting a winning condition from server' do
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
      expect(subject.gamestate.condition.winner.name).to eq("Winning Player")
      expect(subject.gamestate.condition.reason).to eq("R2")
    end
  end

  context 'when receiving a new board' do
    it 'creates the new board in the gamestate' do
      server_message <<-XML
        <board>
          <fields>
            <field x="0" y="0" state="EMPTY"/>
            <field x="0" y="1" state="RED"/>
            <field x="0" y="2" state="RED"/>
            <field x="0" y="3" state="RED"/>
            <field x="0" y="4" state="RED"/>
            <field x="0" y="5" state="RED"/>
            <field x="0" y="6" state="RED"/>
            <field x="0" y="7" state="RED"/>
            <field x="0" y="8" state="RED"/>
            <field x="0" y="9" state="EMPTY"/>
          </fields>
          <fields>
            <field x="1" y="0" state="BLUE"/>
            <field x="1" y="1" state="EMPTY"/>
            <field x="1" y="2" state="EMPTY"/>
            <field x="1" y="3" state="EMPTY"/>
            <field x="1" y="4" state="EMPTY"/>
            <field x="1" y="5" state="EMPTY"/>
            <field x="1" y="6" state="EMPTY"/>
            <field x="1" y="7" state="EMPTY"/>
            <field x="1" y="8" state="EMPTY"/>
            <field x="1" y="9" state="BLUE"/>
          </fields>
          <fields>
            <field x="2" y="0" state="BLUE"/>
            <field x="2" y="1" state="EMPTY"/>
            <field x="2" y="2" state="EMPTY"/>
            <field x="2" y="3" state="EMPTY"/>
            <field x="2" y="4" state="EMPTY"/>
            <field x="2" y="5" state="OBSTRUCTED"/>
            <field x="2" y="6" state="EMPTY"/>
            <field x="2" y="7" state="EMPTY"/>
            <field x="2" y="8" state="EMPTY"/>
            <field x="2" y="9" state="BLUE"/>
          </fields>
          <fields>
            <field x="3" y="0" state="BLUE"/>
            <field x="3" y="1" state="EMPTY"/>
            <field x="3" y="2" state="EMPTY"/>
            <field x="3" y="3" state="EMPTY"/>
            <field x="3" y="4" state="EMPTY"/>
            <field x="3" y="5" state="EMPTY"/>
            <field x="3" y="6" state="EMPTY"/>
            <field x="3" y="7" state="EMPTY"/>
            <field x="3" y="8" state="EMPTY"/>
            <field x="3" y="9" state="BLUE"/>
          </fields>
          <fields>
            <field x="4" y="0" state="BLUE"/>
            <field x="4" y="1" state="EMPTY"/>
            <field x="4" y="2" state="EMPTY"/>
            <field x="4" y="3" state="EMPTY"/>
            <field x="4" y="4" state="EMPTY"/>
            <field x="4" y="5" state="EMPTY"/>
            <field x="4" y="6" state="EMPTY"/>
            <field x="4" y="7" state="EMPTY"/>
            <field x="4" y="8" state="EMPTY"/>
            <field x="4" y="9" state="BLUE"/>
          </fields>
          <fields>
            <field x="5" y="0" state="BLUE"/>
            <field x="5" y="1" state="EMPTY"/>
            <field x="5" y="2" state="EMPTY"/>
            <field x="5" y="3" state="EMPTY"/>
            <field x="5" y="4" state="EMPTY"/>
            <field x="5" y="5" state="EMPTY"/>
            <field x="5" y="6" state="EMPTY"/>
            <field x="5" y="7" state="EMPTY"/>
            <field x="5" y="8" state="EMPTY"/>
            <field x="5" y="9" state="BLUE"/>
          </fields>
           <fields>
            <field x="6" y="0" state="BLUE"/>
            <field x="6" y="1" state="EMPTY"/>
            <field x="6" y="2" state="EMPTY"/>
            <field x="6" y="3" state="OBSTRUCTED"/>
            <field x="6" y="4" state="EMPTY"/>
            <field x="6" y="5" state="EMPTY"/>
            <field x="6" y="6" state="EMPTY"/>
            <field x="6" y="7" state="EMPTY"/>
            <field x="6" y="8" state="EMPTY"/>
            <field x="6" y="9" state="BLUE"/>
          </fields>
          <fields>
            <field x="7" y="0" state="BLUE"/>
            <field x="7" y="1" state="EMPTY"/>
            <field x="7" y="2" state="EMPTY"/>
            <field x="7" y="3" state="EMPTY"/>
            <field x="7" y="4" state="EMPTY"/>
            <field x="7" y="5" state="EMPTY"/>
            <field x="7" y="6" state="EMPTY"/>
            <field x="7" y="7" state="EMPTY"/>
            <field x="7" y="8" state="EMPTY"/>
            <field x="7" y="9" state="BLUE"/>
          </fields>
          <fields>
            <field x="8" y="0" state="BLUE"/>
            <field x="8" y="1" state="EMPTY"/>
            <field x="8" y="2" state="EMPTY"/>
            <field x="8" y="3" state="EMPTY"/>
            <field x="8" y="4" state="EMPTY"/>
            <field x="8" y="5" state="EMPTY"/>
            <field x="8" y="6" state="EMPTY"/>
            <field x="8" y="7" state="EMPTY"/>
            <field x="8" y="8" state="EMPTY"/>
            <field x="8" y="9" state="BLUE"/>
          </fields>
          <fields>
            <field x="9" y="0" state="EMPTY"/>
            <field x="9" y="1" state="RED"/>
            <field x="9" y="2" state="RED"/>
            <field x="9" y="3" state="RED"/>
            <field x="9" y="4" state="RED"/>
            <field x="9" y="5" state="RED"/>
            <field x="9" y="6" state="RED"/>
            <field x="9" y="7" state="RED"/>
            <field x="9" y="8" state="RED"/>
            <field x="9" y="9" state="EMPTY"/>
          </fields>
        </board>
      XML
      board = subject.gamestate.board
      expect(board.fields.size).to eq(10)
    end
  end

  it 'converts a move to xml' do
    move = Move.new(3, 5, Direction::UP_RIGHT)
    # NOTE that this is brittle because XML formatting (whitespace, attribute
    # order) is arbitrary.
    expect(subject.move_to_xml(move)).to eq <<-XML
<data class="move" x="3" y="5" direction="UP_RIGHT">
</data>
    XML
  end

=end
end
