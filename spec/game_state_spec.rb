# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

include GameStateHelpers

RSpec.describe GameState do

  subject(:gamestate) { described_class.new }

  before do
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
  end

  it 'holds the board' do
    expect(subject.field(0, 0)).to eq(Field.new(0, 0, [Piece.new(PlayerColor::RED, PieceType::BEE)], false))
  end

  it 'is clonable' do
    clone = gamestate.clone
    clone.turn += 1
    clone.board.add_field(Field.new(0, 0, [], true))
    clone.current_player_color = PlayerColor::BLUE
    # if clone is not independent, changes should also affect the original
    # gamestate
    expect(gamestate.turn).to_not eq(clone.turn)
    expect(gamestate.board.field(0, 0)).to_not eq(clone.board.field(0, 0))
    expect(gamestate.current_player_color).to_not eq(clone.current_player_color)
  end

  it 'returns all own fields' do
    expect(gamestate.own_fields.size).to eq(1)
  end

=begin
  it 'calculates all possible moves' do
    expect(gamestate.possible_moves.size).to eq(16 * 3)
  end
=end
end
