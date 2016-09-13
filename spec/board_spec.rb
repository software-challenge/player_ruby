# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Board do
  subject(:board) { Board.new }

  context 'method get_neighbor' do
    it 'should give new coordinates for all directions' do
      Direction.each do |d|
        new_x, new_y = board.get_neighbor(0, 0, d)
        expect([new_x, new_y]).to_not eq([0, 0])
      end
    end
  end

  context 'method get_in_direction' do
    before do
      (-3..3).each do |x|
        (-3..3).each do |y|
          board.add_field(Field.new(FieldType::WATER, x, y, 0, 0, 0))
        end
      end
    end

    it 'should return the field in this direction' do
      expect(
        board.get_in_direction(0, 0, Direction::RIGHT, 2)
      ).to eq(board.fields[2][0])
    end
  end
end
