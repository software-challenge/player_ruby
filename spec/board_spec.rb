# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.describe Board do
  let(:gamestate) { GameState.new }
  subject(:board) { gamestate.board }

  context 'method field' do

    before {state_from_string!('rb0 C C I H S C C C C C C C G', gamestate)}

    it 'should return new invalid fields for indices out of range' do
      expect(board.field(99).type).to eq(FieldType::INVALID)
      expect(board.field(-1).type).to eq(FieldType::INVALID)
    end

    it 'should return the field at the index' do
      field = Field.new(FieldType::HARE, 23)
      board.add_field(field)
      expect(board.field(23)).to eq(field)
    end
  end
end
