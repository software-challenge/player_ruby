# encoding: UTF-8
# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.describe GameState do
  subject(:gamestate) { described_class.new }

  before do
    board =
      <<~BOARD
      1 T 2 4 2 2 3 2 
      1 T 0 3 2 2 O 0 
      1 2 1 2 2 0 2 O 
      O O 2 1 0 0 2 1 
      1 2 1 0 1 2 0 1 
      2 2 0 2 2 1 2 1 
      0 T 2 2 3 0 1 0 
      2 3 2 T 4 2 1 1 
      BOARD
    state_from_string!(board, gamestate)
  end

  it 'holds the board' do
    expect(subject.field(0, 3)).to eq(Field.new(0, 3, Piece.new(Team::ONE, Coordinates.new(0, 3))))
  end

  it 'is clonable' do
    clone = gamestate.clone
    clone.turn += 1
    clone.board.add_field(Field.new(0, 0, Piece.new(Team::TWO, Coordinates.new(0,0))))
    # if clone is independent, changes will not affect the original gamestate
    expect(gamestate.turn).to_not eq(clone.turn)
    expect(gamestate.board.field(0, 0)).to_not eq(clone.board.field(0, 0))
  end

  it 'returns all own fields' do
    expect(gamestate.own_fields.size).to eq(4)
  end

  it 'performs moves' do
    # expect do
    #   move = SkipMove.new
    #   gamestate.perform!(move)
    # end.not_to raise_error
    expect do
      move = Move.new(
        nil,
        Coordinates.new(0, 0)
      )
      gamestate.perform!(move)
    end.not_to raise_error
  end

  #   it 'calculates all possible moves' do
  #     expect(gamestate.possible_moves.size).to eq(16 * 3)
  #   end
end
