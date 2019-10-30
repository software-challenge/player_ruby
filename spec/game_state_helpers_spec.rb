# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

RSpec.describe GameStateHelpers do
  include GameStateHelpers

  let(:gamestate) { GameState.new }

  it 'should be createable by the helper' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         ------------------
        --------------------
       ----------RQ----------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    expect(gamestate.board.field(0, 0)).to be_a(Field)
    expect(gamestate.board.field(0, 0).pieces.size).to eq(1)
    expect(gamestate.board.field(0, 0).pieces.first.color).to eq(PlayerColor::RED)
    expect(gamestate.board.field(0, 0).pieces.first.type).to eq(PieceType::BEE)
  end
  it 'should raise an error on illegal format' do
    board =
      <<~BOARD
            XY----------
           --------------
          ----------------
         ------------------
        --------------------
       ----------RQ----------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    expect do
      state_from_string!(board, gamestate)
    end.to raise_error(GameStateHelpers::BoardFormatError)
  end

  it 'should place fields on the right coordinates' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         ------------------
        --------------------
       ----------RQ----------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    c = CubeCoordinates.new(-2, 1)
    expect(gamestate.board.field_at(c).coordinates).to eq(c)
  end
end
