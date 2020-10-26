# encoding: UTF-8
# frozen_string_literal: true

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
include Constants

RSpec.describe GameRuleLogic do
  subject { GameRuleLogic }
  let(:gamestate) { GameState.new }

  context 'on game start' do
    before do
      board =
        <<~BOARD
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
          _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
      BOARD
      state_from_string!(board, gamestate)
    end

    it 'calculates current points' do
      expect(GameRuleLogic.get_points_from_undeployed(gamestate.undeployed_pieces(Color::RED), false)).to eq(0)
    end

  end

  context 'corner predicate' do
    it 'identifies all corners as corner' do
      expect(GameRuleLogic.corner?(Coordinates.new(0, 0))).to be true
      expect(GameRuleLogic.corner?(Coordinates.new(0, 19))).to be true
      expect(GameRuleLogic.corner?(Coordinates.new(19, 0))).to be true
      expect(GameRuleLogic.corner?(Coordinates.new(19, 19))).to be true
    end

    it 'identifies other places not as corner' do
      expect(GameRuleLogic.corner?(Coordinates.new(1, 0))).to be false
      expect(GameRuleLogic.corner?(Coordinates.new(12, 3))).to be false
      expect(GameRuleLogic.corner?(Coordinates.new(99, 3))).to be false
    end
  end
end
