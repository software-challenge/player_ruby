# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

# Needed when chaining matchers. expect(...).not_to raise_error().and .. is not
# allowed.
RSpec::Matchers.define_negated_matcher :not_raise_error, :raise_error

include GameStateHelpers

RSpec.describe Advance do

  let(:gamestate) { GameState.new }

  context 'when a player is on start field' do
    before { state_from_string!('r0 C C C bC C C C C C C C C G', gamestate) }

    it 'should be valid to advance' do
      expect {
        Advance.new(1).perform!(gamestate)
      }.not_to raise_error
    end

    it 'should change the players position when advancing' do
      expect {
        Advance.new(1).perform!(gamestate)
      }.to change{gamestate.current_player.index}.from(0).to(1)
    end

    it 'should change the players carrots when advancing' do
      expect {
        Advance.new(3).perform!(gamestate)
      }.to change{gamestate.current_player.carrots}.by(-6)
    end

    it 'should not be possible to move past field 11' do
      expect {
        Advance.new(12).perform!(gamestate)
      }.to raise_error(InvalidMoveException, /Nicht genug Karotten/)
    end

    it 'should not be possible to move past the last field with unlimited carrots' do
      gamestate.current_player.carrots = 9999
      expect {
        Advance.new(14).perform!(gamestate)
      }.to raise_error(InvalidMoveException, /Zielfeld.+nicht vorhanden/)
    end
  end

  context 'when a player is on a hare field' do
    before {state_from_string!('0 C C rH C C C bC C C C C C G', gamestate)}

    it 'should be valid to play the take or drop carrots card' do
      expect {
        Card.new(CardType::TAKE_OR_DROP_CARROTS, 20).perform!(gamestate)
      }.not_to raise_error
    end

    it 'should be valid to play the eat salad card' do
      expect {
        Card.new(CardType::EAT_SALAD).perform!(gamestate)
      }.not_to raise_error
    end

    context 'when a player is first' do
      before {state_from_string!('0 C bC C rH C C C C C C C C G', gamestate)}
      it 'should be valid to play the fall back card' do
        expect {
          Card.new(CardType::FALL_BACK).perform!(gamestate)
        }.not_to raise_error
      end
    end

    context 'when a player is second' do
      before {state_from_string!('0 C C rH C C C bC C C C C C G', gamestate)}
      it 'should be valid to play the hurry ahead card' do
        expect {
          Card.new(CardType::HURRY_AHEAD).perform!(gamestate)
        }.not_to raise_error
      end
    end
  end
end

RSpec.describe Skip do

  let(:gamestate) { GameState.new }

  it 'is performable, but does nothing' do
    expect {
      Skip.new.perform!(gamestate)
    }.not_to raise_error
  end

end

RSpec.describe EatSalad do

  let(:gamestate) { GameState.new }

  context 'when player is on salad field' do
    before {state_from_string!('0 C bC C rS C C C C C C C C G', gamestate)}
    it 'changes the number of salads' do
      expect {
        EatSalad.new.perform!(gamestate)
      }.to change{gamestate.current_player.salads }.from(5).to(4)
    end
  end

end

RSpec.describe ExchangeCarrots do

  let(:gamestate) { GameState.new }

  context 'when player is on carrot field' do
    before {state_from_string!('0 C bC C rC C C C C C C C C G', gamestate)}
    it 'changes the number of carrots' do
      [-10, 10].each do |c|
        expect {
          ExchangeCarrots.new(c).perform!(gamestate)
        }.to change{gamestate.current_player.carrots }.by(c)
      end
    end
  end

end

RSpec.describe FallBack do

  let(:gamestate) { GameState.new }

  context 'when player is behind a hedgehog field' do
    before {state_from_string!('0 I bC C rC C C C C C C C C G', gamestate)}
    it 'places the player on the hedgehog field' do
      expect {
        FallBack.new.perform!(gamestate)
      }.to change{gamestate.current_player.index }.from(4).to(1)
    end
  end

end
