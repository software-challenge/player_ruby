# encoding: utf-8
# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Move do
  include GameStateHelpers

  subject(:move) { described_class.new(3, 4, Direction::UP) }

  it 'should be equal to a move with the same coordinates and direction' do
    other = described_class.new(3, 4, Direction::UP)
    other.add_hint(DebugHint.new('hint'))
    move.add_hint(DebugHint.new('hint'))
    expect(move).to eq(other)
  end
end
