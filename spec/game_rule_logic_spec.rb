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

RSpec.describe GameRuleLogic do

  subject { GameRuleLogic }
  let(:gamestate) { GameState.new }

  context 'on game start' do
    before do
      field =
        <<~FIELD
          ~ R R R R R R R R ~
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          B ~ ~ O ~ ~ ~ ~ ~ B
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          B ~ ~ ~ ~ O ~ ~ ~ B
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          ~ R R R R R R R R ~
        FIELD
      state_from_string!(field, gamestate)
    end

    it 'is valid to move own fish' do
      expect(subject.valid_move(Move.new(1, 0, Direction::UP), gamestate.board)).to be true
    end

    it 'is not valid to move an empty field' do
      expect(subject.valid_move(Move.new(2, 1, Direction::UP), gamestate.board)).to be false
    end

    it 'is not valid to move a fish from other player' do
      expect(
        subject.valid_move(Move.new(0, 1, Direction::RIGHT), gamestate.board)
      ).to be false
    end

    it 'is not valid to move an obstructed field' do
      expect(
        subject.valid_move(Move.new(5, 3, Direction::RIGHT), gamestate.board)
      ).to be false
    end

    it 'is not valid to move onto an obstructed field'
    it 'is not valid to move out of the board'
  end

  context 'when a player can win'

end
