# encoding: UTF-8

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
    it 'should update the game state' do
      pending 'migrate to hase und igel'
      server_message <<-XML
        <state class="state" turn="2" startPlayer="RED" currentPlayer="BLUE" freeTurn="false">
        <red displayName="Spieler 1" color="RED" points="13" x="-1" y="1" direction="RIGHT" speed="1" coal="6" tile="0" passenger="1"/>
        <blue displayName="Spieler 2" color="BLUE" points="42" x="-1" y="-1" direction="UP_RIGHT" speed="2" coal="6" tile="0" passenger="0"/>
      XML
      expect(subject.gamestate.turn).to eq(2)
      expect(subject.gamestate.start_player_color).to eq(PlayerColor::RED)
      expect(subject.gamestate.current_player_color).to eq(PlayerColor::BLUE)
      expect(subject.gamestate.red.points).to eq(13)
      expect(subject.gamestate.red.name).to eq('Spieler 1')
      expect(subject.gamestate.red.direction).to eq(Direction::RIGHT)
      expect(subject.gamestate.red.x).to eq(-1)
      expect(subject.gamestate.red.y).to eq(1)
      expect(subject.gamestate.red.passengers).to eq(1)
      expect(subject.gamestate.red.velocity).to eq(1)
      expect(subject.gamestate.red.movement).to eq(1)
      expect(subject.gamestate.blue.points).to eq(42)
      expect(subject.gamestate.blue.direction).to eq(Direction::UP_RIGHT)
      expect(subject.gamestate.blue.x).to eq(-1)
      expect(subject.gamestate.blue.y).to eq(-1)
      expect(subject.gamestate.blue.passengers).to eq(0)
      expect(subject.gamestate.blue.velocity).to eq(2)
      expect(subject.gamestate.blue.movement).to eq(2)
    end

    it 'should update the last move, if it exists in the gamestate' do
      pending 'migrate to hase und igel'
      server_message <<-XML
        <state class="state" turn="2" startPlayer="RED" currentPlayer="BLUE" freeTurn="false">
        <lastMove>
          <push order="3" direction="RIGHT"/>
          <acceleration order="0" acc="1"/>
          <turn order="2" direction="-1"/>
          <advance order="1" distance="2"/>
        </lastMove>
      XML
      move = Move.new
      move.add_action(Acceleration.new(1))
      move.add_action(Advance.new(2))
      move.add_action(Turn.new(-1))
      move.add_action(Push.new(Direction::RIGHT))
      expect(subject.gamestate.lastMove).to eq(move)
    end

    it 'should set the additional free turn for the player' do
      pending 'migrate to hase und igel'
      server_message <<-XML
        <state class="state" turn="2" startPlayer="RED" currentPlayer="BLUE" freeTurn="true">
      XML
      expect(subject.gamestate.additional_free_turn_after_push).to eq(true)
    end
  end

  context 'when getting a winning condition from server' do
    it 'should close the connection' do
      expect(network).to receive(:disconnect)
      server_message '<result />'
    end
    it 'should set the winning player' do
      pending 'migrate to hase und igel'
      expect(network).to receive(:disconnect)
      server_message <<-XML
        <result>
<definition>
      <fragment name="Siegpunkte">
        <aggregation>SUM</aggregation>
        <relevantForRanking>false</relevantForRanking>
      </fragment>
      <fragment name="Punkte">
        <aggregation>SUM</aggregation>
        <relevantForRanking>true</relevantForRanking>
      </fragment>
      <fragment name="Passagiere">
        <aggregation>SUM</aggregation>
        <relevantForRanking>true</relevantForRanking>
      </fragment>
    </definition>
<score cause="REGULAR">
      <part>2</part>
      <part>20</part>
      <part>1</part>
    </score>
<score cause="RULE_VIOLATION" reason="Nicht genug Kohle f&#xFC;r Drehung.">
      <part>0</part>
      <part>19</part>
      <part>0</part>
    </score>
<winner displayName="Winning Player" x="4" y="10" direction="LEFT" tile="3" passenger="1" points="20" class="player" coal="2" speed="3" color="RED"/>
        </result>
      XML
      expect(subject.gamestate.condition.winner.name).to eq("Winning Player")
    end
  end

  context 'when receiving a new board' do
    it 'should create the new board in the gamestate' do
      pending 'migrate to hase und igel'
      server_message <<-XML
        <board>
          <tiles>
            <tile index="2" direction="1">
              <fields>
                <field type="WATER" x="-2" y="2" points="1" />
                <field type="WATER" x="-2" y="-2" points="2" />
                <field type="WATER" x="-1" y="2" points="3 "/>
                <field type="WATER" x="-1" y="1"/>
                <field type="WATER" x="-1" y="0"/>
                <field type="WATER" x="-1" y="-1"/>
                <field type="WATER" x="-1" y="-2"/>
                <field type="WATER" x="0" y="2"/>
                <field type="WATER" x="0" y="1"/>
                <field type="WATER" x="0" y="0"/>
                <field type="WATER" x="0" y="-1"/>
                <field type="WATER" x="0" y="-2"/>
                <field type="SANDBANK" x="1" y="1"/>
                <field type="WATER" x="1" y="0"/>
                <field type="WATER" x="1" y="-1"/>
                <field type="WATER" x="1" y="-2"/>
                <field type="WATER" x="1" y="2"/>
                <field type="PASSENGER3" x="2" y="1"/>
                <field type="WATER" x="2" y="0"/>
                <field type="WATER" x="2" y="-1"/>
              </fields>
            </tile>
          </tiles>
        </board>
      XML
      board = subject.gamestate.board
      expect(board.fields.size).to eq(20)
      expect(board.fields[[0, 0]].type).to eq(FieldType::WATER)
      expect(board.fields[[1, 1]].type).to eq(FieldType::SANDBANK)
      expect(board.fields[[2, 1]].type).to eq(FieldType::PASSENGER3)
      expect(board.fields[[-2, 2]].points).to eq(1)
      expect(board.fields[[-2, -2]].points).to eq(2)
      expect(board.fields[[-1, 2]].points).to eq(3)
      expect(board.fields.values).to all(
        have_attributes(index: 2, direction: 1)
      )
    end
  end

  it 'should convert a move to xml' do
    pending 'migrate to hase und igel'
    move = Move.new
    move.add_action(Acceleration.new(2))
    move.add_action(Turn.new(1))
    move.add_action(Advance.new(3))
    move.add_action(Push.new(Direction::RIGHT))
    # NOTE that this is brittle because XML formatting (whitespace, attribute
    # order) is arbitrary.
    expect(subject.move_to_xml(move)).to eq <<-XML
<data class="move">
  <acceleration acc="2" order="0"/>
  <turn direction="1" order="1"/>
  <advance distance="3" order="2"/>
  <push direction="RIGHT" order="3"/>
</data>
    XML
  end
end
