# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.xdescribe GameState do

  subject(:gamestate) { described_class.new }

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

  it 'holds the board' do
    expect(subject.field(0, 0)).to eq(Field.new(0, 0, FieldType::EMPTY))
  end

  it 'is clonable' do
    clone = gamestate.deep_clone
    clone.turn += 1
    clone.board.add_field(Field.new(0, 0, FieldType::RED))
    clone.current_player_color = PlayerColor::BLUE
    # if clone is not independent, changes should also affect the original
    # gamestate
    expect(gamestate.turn).to_not eq(clone.turn)
    expect(gamestate.board.field(0, 0)).to_not eq(clone.board.field(0, 0))
    expect(gamestate.current_player_color).to_not eq(clone.current_player_color)
  end

  it 'returns all own fields' do
    expect(gamestate.own_fields.size).to eq(16)
  end

  it 'calculates all possible moves' do
    expect(gamestate.possible_moves.size).to eq(16 * 3)
  end
end
