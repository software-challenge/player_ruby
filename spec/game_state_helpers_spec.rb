# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe GameStateHelpers do
  include GameStateHelpers

  let(:gamestate) { GameState.new }

  it 'should be createable by the helper'
  it 'should raise an error on illegal format'
end
