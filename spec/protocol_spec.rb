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
    it 'updates the game state' do
      server_message <<-XML
        <state class="state" turn="2" startPlayer="RED" currentPlayer="BLUE">
        <red displayName="Spieler 1" color="RED" index="3" carrots="100" salads="2">
           <cards>
             <type>TAKE_OR_DROP_CARROTS</type>
             <type>EAT_SALAD</type>
             <type>HURRY_AHEAD</type>
             <type>FALL_BACK</type>
           </cards>
           <lastNonSkipAction class="fallBack" order="0"/>
        </red>
        <blue displayName="Spieler 2" color="BLUE" index="23" carrots="42" salads="0">
           <cards>
             <type>FALL_BACK</type>
             <type>HURRY_AHEAD</type>
           </cards>
           <lastNonSkipAction class="exchangeCarrots" order="0" value="10"/>
        </blue>
      XML
      expect(subject.gamestate.turn).to eq(2)
      expect(subject.gamestate.start_player_color).to eq(PlayerColor::RED)
      expect(subject.gamestate.current_player_color).to eq(PlayerColor::BLUE)
      expect(subject.gamestate.current_player).to_not be_nil
      expect(subject.gamestate.red.name).to eq('Spieler 1')
      expect(subject.gamestate.red.index).to eq(3)
      expect(subject.gamestate.red.carrots).to eq(100)
      expect(subject.gamestate.red.salads).to eq(2)
      expect(subject.gamestate.red.cards).to contain_exactly(
                                                 CardType::FALL_BACK,
                                                 CardType::EAT_SALAD,
                                                 CardType::HURRY_AHEAD,
                                                 CardType::TAKE_OR_DROP_CARROTS)
      expect(subject.gamestate.red.last_non_skip_action).to eq(FallBack.new)
      expect(subject.gamestate.blue.name).to eq('Spieler 2')
      expect(subject.gamestate.blue.index).to eq(23)
      expect(subject.gamestate.blue.carrots).to eq(42)
      expect(subject.gamestate.blue.salads).to eq(0)
      expect(subject.gamestate.blue.cards).to contain_exactly(
                                                  CardType::FALL_BACK,
                                                  CardType::HURRY_AHEAD)
      expect(subject.gamestate.blue.last_non_skip_action).to eq(ExchangeCarrots.new(10))
    end

    it 'updates the last move, if it exists in the gamestate' do
      server_message <<-XML
        <state class="state" turn="2" startPlayer="RED" currentPlayer="BLUE">
        <lastMove>
          <card order="3" type="TAKE_OR_DROP_CARROTS" value="20"/>
          <advance distance="3" order="0"/>
          <skip order="2"/>
          <eatSalad order="1"/>
          <fallBack order="5"/>
          <exchangeCarrots order="4" value="-10"/>
        </lastMove>
      XML
      move = Move.new
      move.add_action(Advance.new(3))
      move.add_action(EatSalad.new)
      move.add_action(Skip.new)
      move.add_action(Card.new(CardType::TAKE_OR_DROP_CARROTS, 20))
      move.add_action(ExchangeCarrots.new(-10))
      move.add_action(FallBack.new)
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
            <fragment name="Ø Feldnummer">
              <aggregation>AVERAGE</aggregation>
              <relevantForRanking>true</relevantForRanking>
            </fragment>
            <fragment name="Ø Karotten">
              <aggregation>AVERAGE</aggregation>
              <relevantForRanking>true</relevantForRanking>
            </fragment>
          </definition>
          <score cause="CAUSE1" reason="R1">
            <part>2</part>
            <part>23</part>
            <part>42</part>
          </score>
          <score cause="CAUSE2" reason="R2">
            <part>0</part>
            <part>3</part>
            <part>100</part>
          </score>
          <winner class="player" displayName="Winning Player" color="BLUE" index="23" carrots="42" salads="0">
            <cards>
              <type>FALL_BACK</type>
              <type>HURRY_AHEAD</type>
            </cards>
            <lastNonSkipAction class="exchangeCarrots" order="0" value="10"/>
          </winner>
        </data>
      XML
      expect(subject.gamestate.condition.winner.name).to eq("Winning Player")
      expect(subject.gamestate.condition.winner.cards).to contain_exactly(
                                                              CardType::FALL_BACK,
                                                              CardType::HURRY_AHEAD)
    end
  end

  context 'when receiving a new board' do
    it 'creates the new board in the gamestate' do
      server_message <<-XML
        <board>
          <fields index="0" type="START" />
          <fields index="1" type="CARROT" />
          <fields index="3" type="POSITION_1" />
          <fields index="4" type="POSITION_2" />
          <fields index="5" type="HEDGEHOG" />
          <fields index="6" type="SALAD" />
          <fields index="7" type="CARROT" />
          <fields index="2" type="HARE" />
          <fields index="8" type="CARROT" />
          <fields index="9" type="CARROT" />
          <fields index="10" type="GOAL" />
        </board>
      XML
      board = subject.gamestate.board
      expect(board.fields.size).to eq(11)
      expect(board.field(0).type).to eq(FieldType::START)
      expect(board.field(1).type).to eq(FieldType::CARROT)
      expect(board.field(2).type).to eq(FieldType::HARE)
      expect(board.field(3).type).to eq(FieldType::POSITION_1)
      expect(board.field(4).type).to eq(FieldType::POSITION_2)
      expect(board.field(5).type).to eq(FieldType::HEDGEHOG)
      expect(board.field(6).type).to eq(FieldType::SALAD)
      expect(board.field(7).type).to eq(FieldType::CARROT)
      expect(board.field(8).type).to eq(FieldType::CARROT)
      expect(board.field(9).type).to eq(FieldType::CARROT)
      expect(board.field(10).type).to eq(FieldType::GOAL)
    end
  end

  it 'converts a move to xml' do
    move = Move.new
    move.add_action(Advance.new(2))
    move.add_action(Card.new(CardType::EAT_SALAD))
    move.add_action(Card.new(CardType::FALL_BACK))
    move.add_action(Card.new(CardType::HURRY_AHEAD))
    move.add_action(Card.new(CardType::TAKE_OR_DROP_CARROTS, 20))
    move.add_action(Skip.new)
    move.add_action(EatSalad.new)
    move.add_action(FallBack.new)
    move.add_action(ExchangeCarrots.new(-10))
    # NOTE that this is brittle because XML formatting (whitespace, attribute
    # order) is arbitrary.
    expect(subject.move_to_xml(move)).to eq <<-XML
<data class="move">
  <advance distance="2" order="0"/>
  <card type="EAT_SALAD" value="0" order="1"/>
  <card type="FALL_BACK" value="0" order="2"/>
  <card type="HURRY_AHEAD" value="0" order="3"/>
  <card type="TAKE_OR_DROP_CARROTS" value="20" order="4"/>
  <skip order="5"/>
  <eatSalad order="6"/>
  <fallBack order="7"/>
  <exchangeCarrots value="-10" order="8"/>
</data>
    XML
  end
end
