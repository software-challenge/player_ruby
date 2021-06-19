# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe Piece do
  subject(:piece) { Piece.new }

  it 'has a sensible string representation' do
    expect(Piece.new(Color::RED, PieceType::COCKLE).to_s).to eq("RED COCKLE at (0, 0)")
    expect(Piece.new(Color::RED, PieceType::STARFISH, Coordinates.new(3,4)).to_s).to eq("RED STARFISH at (3, 4)")
  end

  it 'has coordinates as position' do
    p = Piece.new(
      Color::RED,
      PieceType::COCKLE,
      Coordinates.new(7, 3)
    )
    expect(p.position).to be_a(Coordinates)
  end
end
