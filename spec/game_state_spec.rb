# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.describe GameState do

  let(:gamestate) {GameState.new}
  subject {state_from_string!('0 C Cr H bS I 2 1 G', gamestate); gamestate}

  it 'should get the next field of type' do
    expect(subject.get_next_field_by_type(FieldType::POSITION_1, 0)).to eq(subject.board.fields[7])
    expect(subject.get_next_field_by_type(FieldType::HARE, 4)).to be_nil
    expect(subject.get_next_field_by_type(FieldType::GOAL, 8)).to be_nil
    expect(subject.get_next_field_by_type(FieldType::GOAL, 7)).to eq(subject.board.fields[8])
  end

  it 'should return nil for illegal index' do
    expect(subject.get_next_field_by_type(FieldType::POSITION_1, -1)).to be_nil
    expect(subject.get_next_field_by_type(FieldType::POSITION_1, 8)).to be_nil
    expect(subject.get_previous_field_by_type(FieldType::POSITION_1, -1)).to be_nil
    expect(subject.get_previous_field_by_type(FieldType::POSITION_1, 0)).to be_nil
    expect(subject.get_previous_field_by_type(FieldType::POSITION_1, 9)).to be_nil
  end

  it 'should get the previous field of type' do
    expect(subject.get_previous_field_by_type(FieldType::HARE, 7)).to eq(subject.board.fields[3])
  end
end
