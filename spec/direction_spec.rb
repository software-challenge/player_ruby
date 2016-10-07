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

    it 'turns in direction with less turns' do
      expect(
        Direction.from_to(Direction::RIGHT, Direction::DOWN_LEFT).direction
      ).to eq(-2)
      expect(
        Direction.from_to(Direction::RIGHT, Direction::UP_LEFT).direction
      ).to eq(2)
    end

  end

  it "is equal even when cloned" do
    first = Direction::RIGHT
    second = first.clone
    expect(first.object_id).not_to eq(second.object_id)
    expect(first).to eq(second)
  end

  it "has equal hashes when the key is equal" do
    first = Direction::RIGHT
    second = first.clone
    expect(first.object_id).not_to eq(second.object_id)
    expect(first.hash).to eq(second.hash)
  end
end
