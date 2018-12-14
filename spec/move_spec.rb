# encoding: utf-8
# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Move do
  include GameStateHelpers

  subject(:move) { Move.new(1, 0, Direction::UP) }

  it 'should be equal to a move with the same coordinates and direction' do
    other = described_class.new(1, 0, Direction::UP)
    other.add_hint(DebugHint.new('hint'))
    move.add_hint(DebugHint.new('hint'))
    expect(move).to eq(other)
  end

  context 'in a game' do
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
          B ~ ~ ~ ~ O ~ ~ ~ B
          B ~ ~ ~ ~ ~ ~ ~ ~ B
          ~ R R R R R R R R ~
        FIELD
      state_from_string!(field, gamestate)
    end

    let(:gamestate) { GameState.new }
    let(:invalid_move) { Move.new(1, 0, Direction::DOWN) }

    it 'is possible to check validity of move instance' do
      expect(move.valid?(gamestate)).to be true
    end

    it 'is possible to perform a valid move' do
      expect{move.perform!(gamestate)}.not_to raise_error
    end

    it 'raises an exception to perform an invalid move' do
      expect{invalid_move.perform!(gamestate)}.to raise_error(InvalidMoveException)
    end
  end
end
