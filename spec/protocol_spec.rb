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
      server_message <<-XML
        <state turn="2" startPlayer="RED" currentPlayer="BLUE" />
      XML
      expect(subject.gamestate.turn).to eq(2)
      expect(subject.gamestate.startPlayerColor).to eq(PlayerColor::RED)
      expect(subject.gamestate.currentPlayerColor).to eq(PlayerColor::BLUE)
    end
  end

  context 'when getting a winning condition from server' do
    it 'should close the connection' do
      expect(network).to receive(:disconnect)
      server_message '<condition />'
    end
  end

  context 'when receiving a new board' do
    it 'should create the new board in the gamestate' do
      server_message <<-XML
        <board>
          <tiles>
            <tile index="0" direction="0">
              <fields>
                <field type="WATER" x="-2" y="2"/>
                <field type="WATER" x="-2" y="-2"/>
                <field type="WATER" x="-1" y="2"/>
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
      expect(board.fields[[2, 1]].type).to eq(FieldType::PASSENGER3)
      expect(board.fields.values).to all(
        have_attributes(index: 0, direction: 0)
      )
    end
  end

  it 'should convert a move to xml' do
    move = Move.new
    move.add_action(Acceleration.new(2))
    move.add_action(Turn.new(1))
    move.add_action(Step.new(3))
    move.add_action(Push.new(0))
    # NOTE that this is brittle because XML formatting (whitespace, attribute
    # order) is arbitrary.
    expect(subject.move_to_xml(move)).to eq <<-XML
<data class="move">
  <acceleration acc="2" order="0"/>
  <turn direction="1" order="1"/>
  <step distance="3" order="2"/>
  <push direction="0" order="3"/>
</data>
    XML
  end
end
