# encoding: UTF-8
# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers
include Constants

RSpec.describe Coordinates do
  it 'is addable' do
    expect(Coordinates.new(3, 4) + Coordinates.new(-1, 1)).to eq(Coordinates.new(2, 5))
  end
end
