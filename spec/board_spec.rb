# encoding: UTF-8
# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.describe Board do
  let(:gamestate) { GameState.new }
  subject(:board) { gamestate.board }

  it 'should have fields initialized' do
    expect(board.field_list.size).to eq(Board::FIELD_AMOUNT)
  end

  it 'should be cloneable' do
    expect(board.clone).to eq(board)
  end

  it 'should be comparable' do
    clone = board.clone
    expect(clone).to eq(board)
    clone.field(0, 0).add_piece(Piece.new(PlayerColor::BLUE, PieceType::ANT))
    expect(clone).not_to eq(board)
  end

  it 'should have fields with correct coordinates' do
    c = CubeCoordinates.new(-2, 1)
    expect(board.field_at(c).coordinates).to eq(c)
  end
end
