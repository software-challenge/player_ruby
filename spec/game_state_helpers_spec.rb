# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe GameStateHelpers do
  include GameStateHelpers

  let(:gamestate) { GameState.new }

  it 'creates a gamestate from a string board representation' do
    board =
      <<~BOARD
      O 1 2 4 2 2 3 2 
      1 1 0 3 2 2 1 0 
      1 2 1 2 2 0 2 2 
      1 1 2 1 0 1 2 1 
      1 2 1 0 1 2 1 1 
      2 2 0 2 2 1 2 1 
      0 1 2 2 3 0 1 1 
      2 3 2 2 4 2 1 1 
      BOARD
    state_from_string!(board, gamestate)

    expect(gamestate.board.field(0, 0)).to be_a(Field)
    expect(gamestate.board.field(0, 0).team).to eq(Team::ONE)
    expect(gamestate.board.field(2, 0)).to be_a(Field)
    expect(gamestate.board.field(2, 0).team).to be_nil
    expect(gamestate.board.field(0, 7)).to be_a(Field)
    expect(gamestate.board.field(0, 7).team).to be_nil
  end

  it 'raises an error on illegal format' do
    board =
      <<~BOARD
      O T 2 4 2 2 3 2 
      1 T 0 3 2 2 1 0 
      1 2 1 2 2 0 2 O 
      O O 2 1 0 0 2 1 
      1 2 1 A 1 2 0 1 
      2 2 0 2 2 1 2 1 
      0 T 2 2 3 0 1 0 
      2 3 2 T 4 2 1 1 
      BOARD
    expect do
      state_from_string!(board, gamestate)
    end.to raise_error(GameStateHelpers::BoardFormatError)
  end
end
