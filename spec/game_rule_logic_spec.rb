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
              ------------
      BOARD
      state_from_string!(board, gamestate)
      gamestate.current_player_color = PlayerColor::BLUE
      move = DragMove.new(CubeCoordinates.new(-1, 4), CubeCoordinates.new(0, 4))
      GameRuleLogic.perform_move(gamestate, move)
      expect(GameRuleLogic.is_bee_blocked(gamestate.board, PlayerColor::RED)).to be true
    end

    it 'should validate set move on empty board' do
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
      move = SetMove.new(gamestate.undeployed_pieces(PlayerColor::RED).first, CubeCoordinates.new(0, 0))
      expect(GameRuleLogic.valid_move?(gamestate, move)).to be true
    end


    it 'should not validate a set move outside of the board' do
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
      move = SetMove.new(gamestate.undeployed_pieces(PlayerColor::RED).first, CubeCoordinates.new(8, 0))
      expect { GameRuleLogic.valid_move?(gamestate, move) }.to raise_error(InvalidMoveException, /is out of bounds/)
    end

    it 'should be valid to set a piece next to opponents one on second turn' do
      board =
        <<~BOARD
            ------------
           --------------
          ----------------
         --BG--------------
        --------------------
       ----------------------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
      state_from_string!(board, gamestate)
      move = SetMove.new(gamestate.undeployed_pieces(PlayerColor::RED).first, CubeCoordinates.new(0, 0))
      expect do
        GameRuleLogic.valid_move?(gamestate, move)
      end.to raise_error(InvalidMoveException, /has to be placed next to other players piece/)
    end

    it 'should not validate setting a piece that is not available undeployed' do
      board =
        <<~BOARD
            ------------
           --------------
          ----------------
         RGBG--------------
        --------------------
       ----------------------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
      state_from_string!(board, gamestate)
      gamestate.undeployed_pieces(PlayerColor::RED).clear
      move = SetMove.new(Piece.new(PlayerColor::RED, PieceType::ANT), CubeCoordinates.new(-4, 4))
      expect do
        GameRuleLogic.valid_move?(gamestate, move)
      end.to raise_error(InvalidMoveException, /Piece is not a undeployed piece/)
    end

    it 'should validate that a set piece is connected to the swarm and doesnt touch opponent' do
      board =
        <<~BOARD
            ------------
           --------------
          ----------------
         RGBG--------------
        --------------------
       ----------------------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
      state_from_string!(board, gamestate)
      invalid1 = SetMove.new(gamestate.undeployed_pieces(PlayerColor::RED).first, CubeCoordinates.new(0, 0))
      expect do
        GameRuleLogic.valid_move?(gamestate, invalid1)
      end.to raise_error(InvalidMoveException, /must touch an own piece/)
      invalid2 = SetMove.new(gamestate.undeployed_pieces(PlayerColor::RED).first, CubeCoordinates.new(-3, 4))
      expect do
        GameRuleLogic.valid_move?(gamestate, invalid2)
      end.to raise_error(InvalidMoveException, /not allowed to touch an opponent/)
      valid1 = SetMove.new(gamestate.undeployed_pieces(PlayerColor::RED).first, CubeCoordinates.new(-4, 5))
      expect(GameRuleLogic.valid_move?(gamestate, valid1)).to be true
    end

    it 'should validate that setting on obstructed fields is not allowed' do
      board =
        <<~BOARD
            ------------
           --------------
          ----------------
         RGBGOO------------
        --------------------
       ----------------------
        --------------------
         ------------------
          ----------------
           --------------
            ------------

      BOARD
      state_from_string!(board, gamestate)
      invalid1 = SetMove.new(gamestate.undeployed_pieces(PlayerColor::RED).first, CubeCoordinates.new(-1, 3))
      expect do
        GameRuleLogic.valid_move?(gamestate, invalid1)
      end.to raise_error(InvalidMoveException, /destination is not empty/)
      invalid2 = SetMove.new(gamestate.undeployed_pieces(PlayerColor::RED).first, CubeCoordinates.new(-1, 2))
      expect do
        GameRuleLogic.valid_move?(gamestate, invalid2)
      end.to raise_error(InvalidMoveException, /must touch an own piece/)
    end

    it 'validates that bee has to be placed on fourth turn' do
      board =
        <<~BOARD
            ------------
           --------------
          ----------------
         RGRGRG------------
        --------------------
       ----------------------
        --------------------
         ------------------
          ----------------
           --------------
            ------------

      BOARD
      state_from_string!(board, gamestate)
      gamestate.turn = 6
      set_ant = SetMove.new(Piece.new(PlayerColor::RED, PieceType::ANT), CubeCoordinates.new(-4, 5))
      expect do
        GameRuleLogic.valid_move?(gamestate, set_ant)
      end.to raise_error(InvalidMoveException, /bee must be placed/)
      skip = SkipMove.new
      expect do
        GameRuleLogic.valid_move?(gamestate, skip)
      end.to raise_error(InvalidMoveException, /other moves can be made/)
      set_bee = SetMove.new(Piece.new(PlayerColor::RED, PieceType::BEE), CubeCoordinates.new(-4, 5))
      expect(GameRuleLogic.valid_move?(gamestate, set_bee)).to be true
    end

    it 'validates that there is an actual piece to drag' do
      board =
        <<~BOARD
            ------------
           --------------
          RQ--------------
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
      move = DragMove.new(CubeCoordinates.new(0, 0), CubeCoordinates.new(0, 1))
      expect do
        GameRuleLogic.valid_move?(gamestate, move)
      end.to raise_error(InvalidMoveException, /no piece to move/)
    end


    it 'refuses to drag a sole piece on the board' do
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
      move = DragMove.new(CubeCoordinates.new(0, 0), CubeCoordinates.new(1, -1))
      expect do
        GameRuleLogic.valid_move?(gamestate, move)
      end.to raise_error(InvalidMoveException, /only beetles are allowed to climb on other/)
    end

    it 'should not allow dragging pieces on other pieces' do
      board =
        <<~BOARD
            ------------
           --------------
          ----------------
         ------------------
        --------------------
       ----------RQBQ--------
        --------------------
         ------------------
          ----------------
           --------------
            ------------

      BOARD
      state_from_string!(board, gamestate)
      move = DragMove.new(CubeCoordinates.new(0, 0), CubeCoordinates.new(1, -1))
      expect do
        GameRuleLogic.valid_move?(gamestate, move)
      end.to raise_error(InvalidMoveException, /no piece to move/)
    end

=begin
    @Test
    fun dragMoveBeeRequiredTest() {
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   ----------------" +
                    "  ------------------" +
                    " --------RBBG--------" +
                    "----------------------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val move = DragMove(CubeCoordinates(0, 1), CubeCoordinates(0, 0))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, move) }
        }
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   ----------------" +
                    "  --------BA--------" +
                    " --------RB----------" +
                    "----------RQ----------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val move = DragMove(CubeCoordinates(0, 0), CubeCoordinates(1, 0))
            assertTrue(GameRuleLogic.validateMove(state, move))
        }
    }

    @Test
    fun dragMoveBeeValidTest() {
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   ----------------" +
                    "  ------------------" +
                    " --------RBBG--------" +
                    "----------RQ----------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val move = DragMove(CubeCoordinates(0, 1), CubeCoordinates(-1, 1))
            assertTrue(GameRuleLogic.validateMove(state, move))
        }
    }

    @Test
    fun dragMoveBeeTooFarTest() {
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   ----------------" +
                    "  ------------------" +
                    " --------RBBG--------" +
                    "----------RQ----------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val move = DragMove(CubeCoordinates(0, -1), CubeCoordinates(2, -2))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, move) }
        }
    }

    @Test
    fun dragMoveBeetleTooFarTest() {
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   ----------------" +
                    "  ------------------" +
                    " --------RBBG--------" +
                    "----------RQ----------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val move = DragMove(CubeCoordinates(0, 0), CubeCoordinates(2, -1))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, move) }
        }
    }

    @Test
    fun dragMoveBeetleDisconnectTest() {
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   ----------------" +
                    "  ------BA----------" +
                    " --------RBBG--------" +
                    "----------RQ----------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val move = DragMove(CubeCoordinates(0, 1), CubeCoordinates(1, 1))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, move) }
        }
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   ----------------" +
                    "  ------BA----------" +
                    " ------RARBBA--------" +
                    "--------BQRQ----------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val move = DragMove(CubeCoordinates(0, 1), CubeCoordinates(1, 1))
            assertTrue(GameRuleLogic.validateMove(state, move))
        }
    }


    @Test
    fun dragMoveBeetleNoJumpTest() {
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   --------RG------" +
                    "  --------BG--RB----" +
                    " ----------RQBQ------" +
                    "----------------------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val move = DragMove(CubeCoordinates(3, -2), CubeCoordinates(3, -1))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, move) }
        }
    }

    @Test
    fun dragMoveBeetleClimbTest() {
        TestGameUtil.updateGamestateWithBoard(state, "" +
                "     ------------" +
                "    --------------" +
                "   ----------------" +
                "  --------RQ--------" +
                " --------RB----------" +
                "----------------------" +
                " --------------------" +
                "  ------------------" +
                "   ----------------" +
                "    --------------" +
                "     ------------")
        val move = DragMove(CubeCoordinates(0, 1), CubeCoordinates(1, 1))
        assertTrue(GameRuleLogic.validateMove(state, move))
    }

    @Test
    fun dragMoveGrasshopperValidTest() {
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   ----------------" +
                    "  ------BABB--------" +
                    " ------BQRBRG--------" +
                    "----------RQ----------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val move = DragMove(CubeCoordinates(1, 0), CubeCoordinates(-2, 3))
            assertTrue(GameRuleLogic.validateMove(state, move))
            val move2 = DragMove(CubeCoordinates(1, 0), CubeCoordinates(1, 2))
            assertTrue(GameRuleLogic.validateMove(state, move2))
        }
    }

    @Test
    fun dragMoveGrasshopperOverEmptyFieldTest() {
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   ----------------" +
                    "  ------BABB--------" +
                    " ------BQRBRG--------" +
                    "----------RQ----------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val move = DragMove(CubeCoordinates(1, -1), CubeCoordinates(-3, 3))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, move) }
        }
    }

    @Test
    fun dragMoveGrasshopperToNeighbourTest() {
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   ----------------" +
                    "  ------BABB--------" +
                    " ------BQRBRG--------" +
                    "----------RQ----------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val move = DragMove(CubeCoordinates(1, -1), CubeCoordinates(1, -2))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, move) }
        }
    }

    @Test
    fun dragMoveAntValidTest() {
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   ----------------" +
                    "  ------RABB--------" +
                    " ------BQRBRG--------" +
                    "----------RQ----------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val move = DragMove(CubeCoordinates(0, 2), CubeCoordinates(1, 2))
            assertTrue(GameRuleLogic.validateMove(state, move))
            val move2 = DragMove(CubeCoordinates(0, 2), CubeCoordinates(0, -1))
            assertTrue(GameRuleLogic.validateMove(state, move2))
        }
    }

    @Test
    fun dragMoveAntAroundObstacleTest() {
        TestGameUtil.updateGamestateWithBoard(state, "" +
                "     ------------" +
                "    --------------" +
                "   ----------------" +
                "  --------OO--------" +
                " ------RQRA----------" +
                "--------OO------------" +
                " --------------------" +
                "  ------------------" +
                "   ----------------" +
                "    --------------" +
                "     ------------")
        val move = DragMove(CubeCoordinates(0, 0), CubeCoordinates(0, 1))
        assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, move) }
        val move2 = DragMove(CubeCoordinates(0, 0), CubeCoordinates(1, 0))
        assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, move2) }
        val move3 = DragMove(CubeCoordinates(0, 0), CubeCoordinates(-1, 0))
        assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, move3) }
    }

    @Test
    fun dragMoveAntIntoBlockedTest() {
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   --------RB------" +
                    "  ------RABB--BB----" +
                    " ------BQRBRGBB------" +
                    "----------RQ----------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val move = DragMove(CubeCoordinates(0, 1), CubeCoordinates(2, -1))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, move) }
        }
    }

    @Test
    fun dragMoveAntAroundBorderTest() {
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   RARQ------------" +
                    "  --BQ--------------" +
                    " --OO----------------" +
                    "----------------------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val move = DragMove(CubeCoordinates(-2, 5), CubeCoordinates(-4, 5))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, move) }
            val move2 = DragMove(CubeCoordinates(-2, 5), CubeCoordinates(0, 5))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, move2) }
            val move3 = DragMove(CubeCoordinates(-2, 5), CubeCoordinates(-2,3))
            assertTrue(GameRuleLogic.validateMove(state, move3))
        }
    }

    @Test
    fun dragMoveAntDisconnectFromSwarmTest() {
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   ----------------" +
                    "  ------RABB--------" +
                    " ------BQRBRG--------" +
                    "----------RQ----------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val move = DragMove(CubeCoordinates(0, 1), CubeCoordinates(2, 1))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, move) }
        }
    }

    @Test
    fun dragMoveSpiderTest() {
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   ----------------" +
                    "  ----------BB------" +
                    " --------RS--BS------" +
                    "--------RBRQBQ--------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val valid1 = DragMove(CubeCoordinates(0, 1), CubeCoordinates(2, 1))
            assertTrue(GameRuleLogic.validateMove(state, valid1))
            val valid2 = DragMove(CubeCoordinates(0, 1), CubeCoordinates(-2, 1))
            assertTrue(GameRuleLogic.validateMove(state, valid2))
            val invalid1 = DragMove(CubeCoordinates(0, 1), CubeCoordinates(1, 0))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, invalid1) }
            val invalid2 = DragMove(CubeCoordinates(0, 1), CubeCoordinates(1, 1))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, invalid2) }
            val invalid3 = DragMove(CubeCoordinates(0, 1), CubeCoordinates(-1, 2))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, invalid3) }
            val invalid4 = DragMove(CubeCoordinates(0, 1), CubeCoordinates(0, 2))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, invalid4) }
            val invalid5 = DragMove(CubeCoordinates(0, 1), CubeCoordinates(3, 0))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, invalid5) }
            val invalid6 = DragMove(CubeCoordinates(0, 1), CubeCoordinates(-1, 0))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, invalid6) }
        }
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   ----------------" +
                    "  ------BB--BB------" +
                    " ------RBRS--BS------" +
                    "--------RBRQBQ--------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val valid1 = DragMove(CubeCoordinates(0, 1), CubeCoordinates(2, 1))
            assertTrue(GameRuleLogic.validateMove(state, valid1))
            val valid2 = DragMove(CubeCoordinates(0, 1), CubeCoordinates(3, 0))
            assertTrue(GameRuleLogic.validateMove(state, valid2))
            val valid3 = DragMove(CubeCoordinates(0, 1), CubeCoordinates(1, 2))
            assertTrue(GameRuleLogic.validateMove(state, valid3))
            val valid4 = DragMove(CubeCoordinates(0, 1), CubeCoordinates(0, 3))
            assertTrue(GameRuleLogic.validateMove(state, valid4))
            val invalid1 = DragMove(CubeCoordinates(0, 1), CubeCoordinates(1, 0))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, invalid1) }
            val invalid2 = DragMove(CubeCoordinates(0, 1), CubeCoordinates(1, 1))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, invalid2) }
            val invalid3 = DragMove(CubeCoordinates(0, 1), CubeCoordinates(-1, 2))
            assertThrows(InvalidMoveException::class.java) { GameRuleLogic.validateMove(state, invalid3) }
        }
    }

    @Test
    fun dragMoveEdgeTest() {
        run {
            TestGameUtil.updateGamestateWithBoard(state, "" +
                    "     ------------" +
                    "    --------------" +
                    "   ----------------" +
                    "  --RBRGBGBB--------" +
                    " RQBGBSRS--BS--------" +
                    "--RS--RBRABQ----------" +
                    " --------------------" +
                    "  ------------------" +
                    "   ----------------" +
                    "    --------------" +
                    "     ------------")
            val move = DragMove(CubeCoordinates(-4, 5), CubeCoordinates(-3, 5))
            assertTrue(GameRuleLogic.validateMove(state, move))
        }
    }

=end
end
