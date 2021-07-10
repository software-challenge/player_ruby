# encoding: UTF-8
# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.describe GameState do
  subject(:gamestate) { described_class.new }

  before do
    board =
      <<~BOARD
      RC RS RR RC RG RG RR RS 
      __ __ __ __ __ __ __ __ 
      __ __ __ __ __ __ __ __ 
      __ __ __ __ __ __ __ __ 
      __ __ __ __ __ __ __ __ 
      __ __ __ __ __ __ __ __ 
      __ __ __ __ __ __ __ __ 
      BS BR BG BC BR BG BC BS 
      BOARD
    state_from_string!(board, gamestate)
  end

  it 'holds the board' do
    expect(subject.field(0, 0)).to eq(Field.new(0, 0, Piece.new(Team::ONE, PieceType::Herzmuschel, Coordinates.new(0,0))))
  end

  it 'is clonable' do
    clone = gamestate.clone
    clone.turn += 1
    clone.board.add_field(Field.new(0, 0, Piece.new(Team::TWO, PieceType::Herzmuschel, Coordinates.new(0,0))))
    # if clone is independent, changes will not affect the original gamestate
    expect(gamestate.turn).to_not eq(clone.turn)
    expect(gamestate.board.field(0, 0)).to_not eq(clone.board.field(0, 0))
  end

  it 'returns all own fields' do
    expect(gamestate.own_fields.size).to eq(8)
  end

  it 'performs moves' do
    expect do
      move = SkipMove.new
      gamestate.perform!(move)
    end.not_to raise_error
    expect do
      move = Move.new(
        Piece.new(
          Team::TWO,
          PieceType::Moewe,
          Coordinates.new(2, 7)
        ),
        Coordinates.new(2, 6)
      )
      gamestate.perform!(move)
    end.not_to raise_error
  end

  #   it 'calculates all possible moves' do
  #     expect(gamestate.possible_moves.size).to eq(16 * 3)
  #   end
end
