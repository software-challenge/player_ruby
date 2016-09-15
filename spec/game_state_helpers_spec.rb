# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe GameStateHelpers do
  include GameStateHelpers

  let(:gamestate) { GameState.new }

  it 'should be createable by the helper' do
    text = <<-BOARD
      .W.W.W.W...
      ..b.B.W.W..
      ...2.W.L.W.
      ..r.S.W.W..
      .W.W.W.W...
    BOARD
    state_from_string!(-2, -2, text, gamestate)
    expect(gamestate.board.fields[-1][-1].type).to eq(FieldType::WATER)
    expect(gamestate.board.fields[0][-1].type).to eq(FieldType::BLOCKED)
    expect(gamestate.board.fields[-1][0].type).to eq(FieldType::PASSENGER2)
    expect(gamestate.red.x).to eq(-1)
    expect(gamestate.red.y).to eq(1)
    expect(gamestate.blue.x).to eq(-1)
    expect(gamestate.blue.y).to eq(-1)
    expect(gamestate.other_player).to eq(gamestate.blue)
  end

  it 'should allow no players on board' do
    text = <<-BOARD
      .W.W.W.W...
      ..W.W.W.W..
      ...W.W.W.W.
      ..W.W.W.W..
      .W.W.W.W...
    BOARD
    expect {
      state_from_string!(-2, -2, text, gamestate)
    }.not_to raise_error
  end

  it 'should put both players on field marked with "8"', focus: true do
    text = <<-BOARD
      .W.W.W.W...
      ..W.W.W.W..
      ...8.W.W.W.
      ..W.W.W.W..
      .W.W.W.W...
    BOARD
    state_from_string!(-2, -2, text, gamestate)
    expect(gamestate.red.x).to eq(-1)
    expect(gamestate.red.y).to eq(0)
    expect(gamestate.blue.x).to eq(-1)
    expect(gamestate.blue.y).to eq(0)
  end
end
