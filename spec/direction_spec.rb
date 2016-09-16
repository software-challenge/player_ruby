# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Direction do

  context 'method from_to' do

    it 'returns turn to the left' do
      expect(
        Direction.from_to(Direction::RIGHT, Direction::DOWN_RIGHT).direction
      ).to eq(-1)
      expect(
        Direction.from_to(Direction::RIGHT, Direction::UP_RIGHT).direction
      ).to eq(1)
    end

  end
end
