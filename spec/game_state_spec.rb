# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.describe GameState do

  subject(:gamestate) { described_class.new }

  before do
    state_from_string!('0 C Cr H bS I 2 1 G', gamestate)
  end

  it 'should get the next field of type' do
    expect(subject.next_field_of_type(FieldType::POSITION_1, 0)).to eq(subject.board.field(7))
    expect(subject.next_field_of_type(FieldType::HARE, 4)).to be_nil
    expect(subject.next_field_of_type(FieldType::GOAL, 8)).to be_nil
    expect(subject.next_field_of_type(FieldType::GOAL, 7)).to eq(subject.board.field(8))
  end

  it 'should return nil for illegal index' do
    expect(subject.next_field_of_type(FieldType::POSITION_1, -1)).to be_nil
    expect(subject.next_field_of_type(FieldType::POSITION_1, 8)).to be_nil
    expect(subject.previous_field_of_type(FieldType::POSITION_1, -1)).to be_nil
    expect(subject.previous_field_of_type(FieldType::POSITION_1, 0)).to be_nil
    expect(subject.previous_field_of_type(FieldType::POSITION_1, 9)).to be_nil
  end

  it 'should get the previous field of type' do
    expect(subject.previous_field_of_type(FieldType::HARE, 7)).to eq(subject.board.field(3))
  end

  it 'is clonable' do
    clone = gamestate.deep_clone
    clone.turn += 1
    clone.board.fields[0] = Field.new(FieldType::CARROT, 0)
    clone.current_player.index += 2
    # if clone is not independent, changes should also affect the original gamestate
    expect(gamestate.turn).to_not eq(clone.turn)
    expect(gamestate.board.fields[0]).to_not eq(clone.board.fields[0])
    expect(gamestate.current_player.index).to_not eq(clone.current_player.index)
  end

  it 'updates the current turn number' do
    state_from_string!('0 C Cr C bC C C C G', gamestate)
    expect(gamestate.turn).to eq(0)
    expect(gamestate.round).to eq(0)
    red = gamestate.current_player
    steps_to_next_carrot_field = gamestate.next_field_of_type(FieldType::CARROT, red.index).index - red.index
    Move.new([Advance.new(steps_to_next_carrot_field)]).perform!(gamestate)
    expect(gamestate.turn).to eq(1)
    expect(gamestate.round).to eq(0)
  end
end
