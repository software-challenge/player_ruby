# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

# Needed when chaining matchers. expect(...).not_to raise_error().and .. is not
# allowed.
RSpec::Matchers.define_negated_matcher :not_raise_error, :raise_error

# matcher to make game rule specs nicer to read
RSpec::Matchers.define :be_valid_to do |what, *args|
  match do |actual|
    actual.send('is_valid_to_' + what.to_s, *args)[0]
  end
end
RSpec::Matchers.define_negated_matcher :not_be_valid_to, :be_valid_to

include GameStateHelpers

RSpec.describe GameRuleLogic do

  subject { GameRuleLogic }
  let(:gamestate) { GameState.new }

  context 'on game start' do
    before do
      board =
        <<~BOARD
            ------------
           --------------
          ----------------
         ------------------
        --------------------
       ----------------------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
      state_from_string!(board, gamestate)
    end

    it 'should translate' do
      c = CubeCoordinates.new(-2, 1)
      expect(Direction::UP_RIGHT.translate(c)).to eq(CubeCoordinates.new(-1, 1))
      expect(Direction::RIGHT.translate(c)).to eq(CubeCoordinates.new(-1, 0))
      expect(Direction::DOWN_RIGHT.translate(c)).to eq(CubeCoordinates.new(-2, 0))
      expect(Direction::DOWN_LEFT.translate(c)).to eq(CubeCoordinates.new(-3, 1))
      expect(Direction::LEFT.translate(c)).to eq(CubeCoordinates.new(-3, 2))
      expect(Direction::UP_LEFT.translate(c)).to eq(CubeCoordinates.new(-2, 2))
    end

    it 'should get neighbours' do
      n = GameRuleLogic.get_neighbours(gamestate.board, CubeCoordinates.new(-2, 1))
      expected = [[-2, 2], [-1, 1], [-1, 0], [-2, 0], [-3, 1], [-3, 2]].map { |c| CubeCoordinates.new(c[0], c[1]) }
      expect(n.map{ |f| f.coordinates }).to match_array(expected)
    end

    it 'should detect if a bee is surrounded' do
      board =
        <<~BOARD
            ------------
           --------------
          ----------------
         ----BBBB----------
        ----BBRQBB----------
       ------BBBB------------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
      state_from_string!(board, gamestate)
      expect(GameRuleLogic.is_bee_blocked(gamestate.board, PlayerColor::RED)).to be true
    end

    it 'should detect if a bee is surrounded on the edge' do
      board =
        <<~BOARD
                                                        RQBQ--------
                                                       BB------------
                                                      --BB------------
                                                     ------------------
                                                    --------------------
                                                   ----------------------
                                                    --------------------
                                                     ------------------
                                                      ----------------
                                                       --------------
                                                        ------------)
      BOARD
      state_from_string!(board, gamestate)
      move = DragMove.new(CubeCoordinates.new(-1, 4), CubeCoordinates.new(0, 4))
      GameRuleLogic.perform_move(gamestate, move)
      expect(GameRuleLogic.is_bee_blocked(gamestate.board, PlayerColor::RED)).to be true
    end

  end

end
