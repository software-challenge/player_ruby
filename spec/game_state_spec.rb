# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.describe GameState do

  subject(:gamestate) { described_class.new }

  before do
    state_from_string!('0 C Cr H bS I 2 1 G', gamestate)
  end

  it 'should get the next field of type' do
    expect(subject.get_next_field_by_type(FieldType::POSITION_1, 0)).to eq(subject.board.field(7))
    expect(subject.get_next_field_by_type(FieldType::HARE, 4)).to be_nil
    expect(subject.get_next_field_by_type(FieldType::GOAL, 8)).to be_nil
    expect(subject.get_next_field_by_type(FieldType::GOAL, 7)).to eq(subject.board.field(8))
  end

  it 'should return nil for illegal index' do
    expect(subject.get_next_field_by_type(FieldType::POSITION_1, -1)).to be_nil
    expect(subject.get_next_field_by_type(FieldType::POSITION_1, 8)).to be_nil
    expect(subject.get_previous_field_by_type(FieldType::POSITION_1, -1)).to be_nil
    expect(subject.get_previous_field_by_type(FieldType::POSITION_1, 0)).to be_nil
    expect(subject.get_previous_field_by_type(FieldType::POSITION_1, 9)).to be_nil
  end

  it 'should get the previous field of type' do
    expect(subject.get_previous_field_by_type(FieldType::HARE, 7)).to eq(subject.board.field(3))
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
end
