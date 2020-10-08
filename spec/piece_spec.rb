# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Piece do
  subject(:piece) { Piece.new }

  it 'has a sensible string representation' do
    expect(Piece.new(Color::RED, PieceShape::MONO).to_s).to eq("RED MONO at (0, 0) rotation NONE")
    expect(Piece.new(Color::RED, PieceShape::MONO, Rotation::LEFT, true).to_s).to eq("RED MONO at (0, 0) rotation LEFT (flipped)")
  end

  def c(x, y)
    Coordinates.new(x, y)
  end

  describe 'PENTO_W' do
    it 'transforms as expected' do
      expected_transformations = {
        [Rotation::NONE, false] =>   CoordinateSet.new([c(0, 0), c(0, 1), c(1, 1), c(1, 2), c(2, 2)]),
        [Rotation::RIGHT, false] =>  CoordinateSet.new([c(0, 2), c(0, 1), c(1, 1), c(1, 0), c(2, 0)]),
        [Rotation::MIRROR, false] => CoordinateSet.new([c(0, 0), c(1, 0), c(1, 1), c(2, 1), c(2, 2)]),
        [Rotation::LEFT, false] =>   CoordinateSet.new([c(0, 2), c(1, 2), c(1, 1), c(2, 1), c(2, 0)]),
        [Rotation::NONE, true] =>    CoordinateSet.new([c(0, 2), c(1, 2), c(1, 1), c(2, 1), c(2, 0)]),
        [Rotation::RIGHT, true] =>   CoordinateSet.new([c(0, 0), c(1, 0), c(1, 1), c(2, 1), c(2, 2)]),
        [Rotation::MIRROR, true] =>  CoordinateSet.new([c(0, 2), c(0, 1), c(1, 1), c(1, 0), c(2, 0)]),
        [Rotation::LEFT, true] =>    CoordinateSet.new([c(0, 0), c(0, 1), c(1, 1), c(1, 2), c(2, 2)])
      }
      shape = PieceShape::PENTO_W
      variants =
        Rotation.map.zip(Array.new(Rotation.size){false}) +
        Rotation.map.zip(Array.new(Rotation.size){true})
      variants.each do |v|
        transformed = shape.transform(v[0], v[1])
        expected = expected_transformations[[v[0], v[1]]]
        expect(transformed).to eq(expected), "sets differ, transformation was to rotate #{v[0].key}#{v[1] ? ' and flip' : ''}"
      end
    end
  end
end
