# encoding: UTF-8
# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.describe Field do
  subject(:field) { Field.new(0, 0) }

  it 'should be possible to add pieces' do
    expect(field.pieces).to be_empty
    field.add_piece(Piece.new(PlayerColor::RED, PieceType::BEE))
    expect(field.pieces.size).to eq(1)
    expect(field.pieces.first).to eq(Piece.new(PlayerColor::RED, PieceType::BEE))
  end

  it 'should be possible to remove pieces' do
    field.add_piece(Piece.new(PlayerColor::RED, PieceType::ANT))
    field.add_piece(Piece.new(PlayerColor::BLUE, PieceType::BEE))
    field.add_piece(Piece.new(PlayerColor::RED, PieceType::ANT))
    expect(field.remove_piece).to eq(Piece.new(PlayerColor::RED, PieceType::ANT))
    expect(field.pieces.size).to eq(2)
  end
end
