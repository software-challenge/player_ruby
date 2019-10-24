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
    expect(gamestate.board.field(0,0)).to be_a(Field)
  end
  it 'should raise an error on illegal format'
end
