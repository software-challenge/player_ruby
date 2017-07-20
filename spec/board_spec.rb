# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Board do
  subject(:board) { Board.new }

  context 'method field' do
    it 'should return new invalid fields for indices out of range' do
      expect(board.field(0).type).to eq(FieldType::INVALID)
    end

    it 'should return the field at the index' do
      field = Field.new(FieldType::HARE, 23)
      board.add_field(field)
      expect(board.field(23)).to eq(field)
    end
  end
end
