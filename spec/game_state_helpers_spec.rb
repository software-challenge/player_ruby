# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe GameStateHelpers do
  include GameStateHelpers

  let(:gamestate) { GameState.new }

  it 'should be createable by the helper' do
    state_from_string!('0 C Cr H bS I 2 1 G', gamestate)
    [FieldType::START, FieldType::CARROT, FieldType::CARROT,
     FieldType::HARE, FieldType::SALAD, FieldType::HEDGEHOG,
     FieldType::POSITION_2, FieldType::POSITION_1, FieldType::GOAL
    ].each_with_index do |type, index|
      expect(gamestate.board.field(index).type).to eq(type)
    end
    expect(gamestate.red.index).to eq(2)
    expect(gamestate.blue.index).to eq(4)
    expect(gamestate.other_player).to eq(gamestate.blue)
  end

  it 'should raise an error on illegal format' do
    expect {
      state_from_string!('CC H bS I 2 1 G', gamestate)
    }.to raise_error GameStateHelpers::BoardFormatError, /multiple types/
    expect {
      state_from_string!('rCb H bS I 2 1 G', gamestate)
    }.to raise_error GameStateHelpers::BoardFormatError, /too many identifiers/
    expect {
      state_from_string!('rb H bS I 2 1 G', gamestate)
    }.to raise_error GameStateHelpers::BoardFormatError, /no type/
  end
end
