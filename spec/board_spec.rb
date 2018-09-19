# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.describe Board do
  let(:gamestate) { GameState.new }
  subject(:board) { gamestate.board }

  context 'method field' do
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

    it 'should return new invalid fields for indices out of range' do
      expect(board.field(99, 0)).to be_nil
      expect(board.field(2, -1)).to be_nil
    end

    it 'should return the field at the index' do
      field = Field.new(2, 3, FieldType::OBSTRUCTED)
      board.add_field(field)
      expect(board.field(2, 3)).to eq(field)
      expect(board.field(0, 0).type).to eq(FieldType::EMPTY)
      expect(board.field(0, 1).type).to eq(FieldType::BLUE)
      expect(board.field(1, 0).type).to eq(FieldType::RED)
      expect(board.field(5, 3).type).to eq(FieldType::OBSTRUCTED)
    end
  end
end
