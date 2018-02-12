# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

# Needed when chaining matchers. expect(...).not_to raise_error().and .. is not
# allowed.
RSpec::Matchers.define_negated_matcher :not_raise_error, :raise_error

# matcher to make game rule specs nicer to read
RSpec::Matchers.define :be_valid_to do |what, *args|
  match do |actual|
    actual.send('is_valid_to_' + what.to_s, *args)[0]
  end
end
RSpec::Matchers.define_negated_matcher :not_be_valid_to, :be_valid_to

include GameStateHelpers

require_relative '../example/client'

RSpec.describe GameRules do

  subject { GameRules }
  let(:gamestate) { GameState.new }

  context 'when a player is on start field' do
    before {state_from_string!('rb0 C C I H S C C C C C C C G', gamestate)}

    it { is_expected.to not_be_valid_to(:fall_back, gamestate) }
    it { is_expected.to not_be_valid_to(:exchange_carrots, gamestate, 10) }
    it { is_expected.to not_be_valid_to(:play_eat_salad, gamestate) }
    it 'is allowed to move forward' do
      is_expected.to be_valid_to(
                         :advance, gamestate, gamestate.next_field_of_type(FieldType::CARROT, 0).index
                     )
    end
    it 'is not allowed to move further forward than carrots are available' do
      is_expected.to not_be_valid_to(
                         :advance, gamestate, gamestate.next_field_of_type(FieldType::CARROT, 11).index
                     )
    end
    it 'is allowed to move onto salad-field (because has two salads on game start)' do
      is_expected.to be_valid_to(
                         :advance, gamestate, gamestate.next_field_of_type(FieldType::SALAD, 0).index
                     )
    end
    it 'is not allowed to move on hedgehog field' do
      is_expected.to not_be_valid_to(
                         :advance, gamestate, gamestate.next_field_of_type(FieldType::HEDGEHOG, 0).index
                     )
    end
    it 'is allowed to move onto hare-field (because has all cards on game start)' do
      is_expected.to be_valid_to(
                         :advance, gamestate, gamestate.next_field_of_type(FieldType::HARE, 0).index
      )
    end
  end

  context 'when a player can reach the goal' do
    before do
      state_from_string!('rb0 C C C C C C C C C C G', gamestate)
      gamestate.current_player.salads = 0
    end

    it 'is allowed to move onto goal' do
      # has enough carrots to reach it and less than or equal to 10 when reached and no salads)
      is_expected.to be_valid_to(
                         :advance, gamestate, gamestate.next_field_of_type(FieldType::GOAL, 0).index
                     )
    end

    it 'is not allowed to move onto goal with to many carrots' do
      gamestate.current_player.carrots = 1000
      is_expected.to not_be_valid_to(
                         :advance, gamestate, gamestate.next_field_of_type(FieldType::GOAL, 0).index
                     )
    end
  end

  context 'when a player is on a salad field' do
    before do
      state_from_string!('b0 C C C rS C C C C C C G', gamestate)
    end

    it 'is allowed to eat a salad' do
      is_expected.to be_valid_to(:eat, gamestate)
    end

    context 'when he already ate a salad there' do
      before do
        gamestate.current_player.last_non_skip_action = EatSalad.new
      end

      it 'is not allowed to eat another salad' do
        is_expected.to not_be_valid_to(:eat, gamestate)
      end

      it 'is expected that he moves on' do
        expect(GameRules.player_must_advance(gamestate)).to be true
      end
    end
  end

  context 'when a player is on a carrot field' do
    before do
      state_from_string!('b0 C C C rC C C C C C C G', gamestate)
    end

    it 'is allowed to take 10 carrots' do
      is_expected.to be_valid_to(:exchange_carrots, gamestate, 10)
    end

    it 'is allowed to put 10 carrots away' do
      is_expected.to be_valid_to(:exchange_carrots, gamestate, -10)
    end

    it 'is not allowed to exchange other quantities of carrots' do
      is_expected.to not_be_valid_to(:exchange_carrots, gamestate, 3)
      is_expected.to not_be_valid_to(:exchange_carrots, gamestate, -3)
      is_expected.to not_be_valid_to(:exchange_carrots, gamestate, 42)
      is_expected.to not_be_valid_to(:exchange_carrots, gamestate, 0)
    end
  end

  context 'calculation of required carrots' do
    it 'is the inverse of calculation of movable fields' do
      (1..44).to_a.each do |m|
        expect(GameRules.calculate_movable_fields(GameRules.calculate_carrots(m))).to eq(m)
      end
    end
  end

  it 'should not enter a infinite loop (stack level to deep)' do
    state_from_string!('bC C H r1 H G', gamestate)
    gamestate.current_player_color = PlayerColor::BLUE
    gamestate.current_player.carrots = 49
    gamestate.current_player.salads = 0
    gamestate.current_player.cards = [
      CardType::TAKE_OR_DROP_CARROTS,
      CardType::HURRY_AHEAD,
      CardType::FALL_BACK
    ]
    expect { gamestate.possible_moves }.not_to raise_error
  end

  it 'should not hang (FIXME: better title)', focus: true do
    state_from_string!('0 C C C H rC bH H 1 2 S I C C H I 1 C 2 I C C S 2 I C H 2 C C I 1 C 2 H C H I 2 H C C S I 1 C 2 C C H I C H C 2 C I S C H C C 1 H G', gamestate)
    gamestate.current_player_color = PlayerColor::BLUE
    gamestate.current_player.carrots = 57
    gamestate.current_player.salads = 4
    gamestate.current_player.cards = [
      CardType::TAKE_OR_DROP_CARROTS,
      CardType::HURRY_AHEAD,
      CardType::FALL_BACK
    ]
    gamestate.current_player.last_non_skip_action = Card.new(CardType::EAT_SALAD)
    expect(gamestate.current_player.index).to eq(6)
    expect(gamestate.other_player.index).to eq(5)
    client = Client.new(0)
    client.gamestate = gamestate
    expect(gamestate.possible_moves.size).to eq(1)
    expect do
      client.move_requested
    end.not_to raise_error
    expect(client.best_move).not_to be_empty
  end
end
