# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Move do

  include GameStateHelpers

  subject(:move) { described_class.new }

  it 'should accept actions to be added' do
    move.add_action(Advance.new(3))
    expect(move.actions.size).to eq(1)
  end

  it 'should be equal to a move with the same actions' do
    other = described_class.new
    other.add_action(Advance.new(2))
    other.add_action(Card.new(CardType::EAT_SALAD))
    other.add_action(Skip.new)
    other.add_action(EatSalad.new)
    other.add_hint(DebugHint.new('hint'))
    move.add_action(Advance.new(2))
    move.add_action(Card.new(CardType::EAT_SALAD))
    move.add_action(Skip.new)
    move.add_action(EatSalad.new)
    move.add_hint(DebugHint.new('hint'))
    expect(move).to eq(other)
  end

  context 'moving forward' do

    let(:gamestate) { GameState.new }
    let(:move) { Move.new }

    before do
      state_from_string!('b0 C C C rS C C C C I H G', gamestate)
    end

    it 'reduces the number of carrots' do
      move.add_action(Advance.new(4))
      expect {
        move.perform!(gamestate)
      }.to change{gamestate.current_player.carrots}.by(-10)
    end

    it 'is not allowed onto hedgehog fields' do
      move.add_action(Advance.new(5))
      expect {
        move.perform!(gamestate)
      }.to raise_error InvalidMoveException, /Auf ein Igelfeld darf nicht vorwärts gezogen werden./
    end

    it 'is not allowed onto hare field without playing a card' do
      move.add_action(Advance.new(6))
      expect {
        move.perform!(gamestate)
      }.to raise_error(InvalidMoveException)
    end
  end

end
