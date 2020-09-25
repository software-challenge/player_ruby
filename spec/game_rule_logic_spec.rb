# encoding: UTF-8
# frozen_string_literal: true

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
include Constants

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
      expect(n.map(&:coordinates)).to match_array(expected)
    end

    it 'should calculate all possible moves' do
      expect(GameRuleLogic.possible_moves(gamestate).size).to eq(STARTING_PIECES.chars.uniq.size * Board::FIELD_AMOUNT)
      board =
        <<~BOARD
            ------------
           --------------
          ----------------
         ------------------
        ------BQ------------
       ----------------------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
      state_from_string!(board, gamestate)
      expect(GameRuleLogic.possible_moves(gamestate).size).to eq(STARTING_PIECES.chars.uniq.size * 6)
      board =
        <<~BOARD
            ------------
           --------------
          ----------------
         ------------------
        ------BGRG----------
       ----------------------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
      state_from_string!(board, gamestate)
      expect(GameRuleLogic.possible_moves(gamestate).size).to eq(STARTING_PIECES.chars.uniq.size * 3)
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
    end.to raise_error(InvalidMoveException, /no path to your destination/)
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
    end.to raise_error(InvalidMoveException, /Only beetles are allowed to climb on other/)
  end

  it 'should require a bee for any drag move' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         ------------------
        --------------------
       ----------RBBG--------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(0, 0), CubeCoordinates.new(0, -1))
    expect do
      GameRuleLogic.valid_move?(gamestate, move)
    end.to raise_error(InvalidMoveException, /have to place the bee/)
  end

  it 'should allow drag moves with bee present' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         ------------------
        --------RBBG--------
       ----------RQ----------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(0, 1), CubeCoordinates.new(-1, 1))
    expect(GameRuleLogic.valid_move?(gamestate, move)).to be true
  end

  it 'should not allow moving the bee more than one field' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         ------------------
        --------RBBG--------
       ----------RQ----------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(0, 0), CubeCoordinates.new(-1, 2))
    expect do
      GameRuleLogic.valid_move?(gamestate, move)
    end.to raise_error(InvalidMoveException, /Destination field is not next to start field/)
  end

  it 'should not allow moving the beetle more than one field' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         ------------------
        --------RBBG--------
       ----------RQ----------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(0, 1), CubeCoordinates.new(2, -1))
    expect do
      GameRuleLogic.valid_move?(gamestate, move)
    end.to raise_error(InvalidMoveException, /Destination field is not next to start field/)
  end

  it 'should check for swarm disconnect on drag move' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         ------BA----------
        --------RBBG--------
       ----------RQ----------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(0, 1), CubeCoordinates.new(-1, 2))
    expect do
      GameRuleLogic.valid_move?(gamestate, move)
    end.to raise_error(InvalidMoveException, /would disconnect swarm/)
  end

  it 'should allow move when swarm doesnt disconnect' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         ------BA----------
        ------RARBBG--------
       --------BQRQ----------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(0, 1), CubeCoordinates.new(-1, 2))
    expect(GameRuleLogic.valid_move?(gamestate, move)).to be true
  end

  it 'should check that pieces cant "jump" over cracks' do
    board =
      <<~BOARD
            ------------
           --------------
          --------RG------
         --------BG--RB----
        ----------RQBQ------
       ----------------------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(3, -1), CubeCoordinates.new(3, 0))
    expect do
      GameRuleLogic.valid_move?(gamestate, move)
    end.to raise_error(InvalidMoveException, /has to move along swarm/)
  end

  it 'should allow beetle to climb on other pieces' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         --------RQ--------
        --------RB----------
       ----------------------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(0, 1), CubeCoordinates.new(1, 1))
    expect(GameRuleLogic.valid_move?(gamestate, move)).to be true
  end

  it 'should check grasshopper drag move validity' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         ------BABB--------
        ------BQRBRG--------
       ----------RQ----------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(1, 0), CubeCoordinates.new(-2, 3))
    expect(GameRuleLogic.valid_move?(gamestate, move)).to be true
    second_move = DragMove.new(CubeCoordinates.new(1, 0), CubeCoordinates.new(1, 2))
    expect(GameRuleLogic.valid_move?(gamestate, second_move)).to be true
  end

  it 'should forbid grasshoppers jumping over empty fields' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         ------BABB--------
        ------BQRBRG--------
       ----------RQ----------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(1, 0), CubeCoordinates.new(-3, 4))
    expect do
      GameRuleLogic.valid_move?(gamestate, move)
    end.to raise_error(InvalidMoveException, /can only jump over occupied fields/)
  end

  it 'should forbid grasshoppers moving only one field' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         ------BABB--------
        ------BQRBRG--------
       ----------RQ----------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(1, 0), CubeCoordinates.new(1, -1))
    expect do
      GameRuleLogic.valid_move?(gamestate, move)
    end.to raise_error(InvalidMoveException, /has to jump over at least one piece/)
  end

  it 'should check validity of ant moves' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         ------RABB--------
        ------BQRBRG--------
       ----------RQ----------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(0, 2), CubeCoordinates.new(1, 2))
    expect(GameRuleLogic.valid_move?(gamestate, move)).to be true
    second_move = DragMove.new(CubeCoordinates.new(0, 2), CubeCoordinates.new(0, -1))
    expect(GameRuleLogic.valid_move?(gamestate, second_move)).to be true
  end

  it 'should forbid moving ant around obstructed fields' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         --------OO--------
        ------RQRA----------
       --------OO------------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(0, 1), CubeCoordinates.new(0, 2))
    expect do
      GameRuleLogic.valid_move?(gamestate, move)
    end.to raise_error(InvalidMoveException, /No path found for ant move/)
    second_move = DragMove.new(CubeCoordinates.new(0, 1), CubeCoordinates.new(1, 1))
    expect do
      GameRuleLogic.valid_move?(gamestate, second_move)
    end.to raise_error(InvalidMoveException, /No path found for ant move/)
    third_move = DragMove.new(CubeCoordinates.new(0, 1), CubeCoordinates.new(0, 0))
    expect do
      GameRuleLogic.valid_move?(gamestate, third_move)
    end.to raise_error(InvalidMoveException, /No path found for ant move/)
  end

  it 'should forbid moving ant into blocked passage' do
    board =
      <<~BOARD
               ------------
              --------------
             --------RB------
            ------RABB--BB----
           ------BQRBRGBB------
          ----------RQ----------
           --------------------
            ------------------
             ----------------
              --------------
               ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(0, 2), CubeCoordinates.new(2, 0))
    expect do
      GameRuleLogic.valid_move?(gamestate, move)
    end.to raise_error(InvalidMoveException, /No path found for ant move/)
  end

  it 'should forbid moving ant around border' do
    board =
      <<~BOARD
           ------------
          --------------
         RARQ------------
        --BQ--------------
       --OO----------------
      ----------------------
       --------------------
        ------------------
         ----------------
          --------------
           ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(-2, 5), CubeCoordinates.new(-4, 5))
    expect do
      GameRuleLogic.valid_move?(gamestate, move)
    end.to raise_error(InvalidMoveException, /No path found for ant move/)
    second_move = DragMove.new(CubeCoordinates.new(-2, 5), CubeCoordinates.new(-2, 3))
    expect(GameRuleLogic.valid_move?(gamestate, second_move)).to be true
  end

  it 'should forbid moving ant when disconnecting the swarm' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         ------RABB--------
        ------BQ--RG--------
       ----------RQ----------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(0, 2), CubeCoordinates.new(-1, 1))
    expect do
      GameRuleLogic.valid_move?(gamestate, move)
    end.to raise_error(InvalidMoveException, /would disconnect swarm/)
  end

  it 'validate spider moves' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         ----------BB------
        --------RS--BS------
       --------RBRQBQ--------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    [[2, 1], [-2, 1]].each do |c|
      valid_move = DragMove.new(CubeCoordinates.new(0, 1), CubeCoordinates.new(c[0], c[1]))
      expect(GameRuleLogic.valid_move?(gamestate, valid_move)).to be true
    end

    [[1, 0], [1, 1], [-1, 2], [0, 2], [3, 0], [-1, 0]].each do |c|
      invalid_move = DragMove.new(CubeCoordinates.new(0, 1), CubeCoordinates.new(c[0], c[1]))
      expect do
        GameRuleLogic.valid_move?(gamestate, invalid_move)
      end.to raise_error(InvalidMoveException, /No path found for spider move/)
    end
  end

  it 'validate more spider moves' do
    board =
      <<~BOARD
              ------------
             --------------
            ----------------
           ------BB--BB------
          ------RBRS--BS------
         --------RBRQBQ--------
          --------------------
           ------------------
            ----------------
             --------------
              ------------
      BOARD
    state_from_string!(board, gamestate)
    [[2, 1], [3, 0], [1, 2], [0, 3]].each do |c|
      valid_move = DragMove.new(CubeCoordinates.new(0, 1), CubeCoordinates.new(c[0], c[1]))
      expect(GameRuleLogic.valid_move?(gamestate, valid_move)).to be true
    end

    [[1, 0, /No path found/], [1, 1, /No path found/], [-1, 2, /allowed to climb/]].each do |c|
      invalid_move = DragMove.new(CubeCoordinates.new(0, 1), CubeCoordinates.new(c[0], c[1]))
      expect do
        GameRuleLogic.valid_move?(gamestate, invalid_move)
      end.to raise_error(InvalidMoveException, c[2])
    end
  end

  it 'valide edge dragging' do
    board =
      <<~BOARD
            ------------
           --------------
          ----------------
         --RBRGBGBB--------
        RQBGBSRS--BS--------
       --RS--RBRABQ----------
        --------------------
         ------------------
          ----------------
           --------------
            ------------
      BOARD
    state_from_string!(board, gamestate)
    move = DragMove.new(CubeCoordinates.new(-4, 5), CubeCoordinates.new(-3, 5))
    expect(GameRuleLogic.valid_move?(gamestate, move)).to be true
  end
end
