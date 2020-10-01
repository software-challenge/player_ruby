# frozen_string_literal: true

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe GameStateHelpers do
  include GameStateHelpers

  let(:gamestate) { GameState.new }

  it 'creates a gamestate from a string board representation' do
    board =
      <<~BOARD
        R _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ B B
        R _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ B
        R R _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ B
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        G _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ Y
        G G G _ _ _ _ _ _ _ _ _ _ _ _ _ _ Y Y Y
      BOARD
    state_from_string!(board, gamestate)
    expect(gamestate.board.field(0, 0)).to be_a(Field)
    expect(gamestate.board.field(0, 0).color).to eq(Color::RED)
    expect(gamestate.board.field(1, 0)).to be_a(Field)
    expect(gamestate.board.field(1, 0).color).to be_nil
    expect(gamestate.board.field(19, 0)).to be_a(Field)
    expect(gamestate.board.field(19, 0).color).to eq(Color::BLUE)
  end
  it 'raises an error on illegal format' do
    board =
      <<~BOARD
        R _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ B B
        R _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ B
        R R _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ B
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ X _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ Y _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
        G _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ Y
        G G G _ _ _ _ _ _ _ _ _ _ _ _ _ _ Y Y Y
      BOARD
    expect do
      state_from_string!(board, gamestate)
    end.to raise_error(GameStateHelpers::BoardFormatError)
  end

  it 'updates undeployed pieces'
end
