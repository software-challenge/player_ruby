# coding: utf-8
# frozen_string_literal: true

require_relative './util/constants'
require_relative 'invalid_move_exception'
require_relative 'set_move'

# Methoden, welche die Spielregeln von Blokus abbilden.
#
# Es gibt hier viele Helfermethoden, die von den beiden Hauptmethoden {GameRuleLogic#valid_move?}
# und {GameRuleLogic.possible_moves} benutzt werden.
class GameRuleLogic
  include Constants

  SUM_MAX_SQUARES = 89

  # Berechne den Punktestand anhand der gegebenen [PieceShape]s.
  # @param undeployed eine Sammlung aller nicht gelegten [PieceShape]s
  # @param monoLast ob der letzte gelegte Stein das Monomino war
  #
  # @return die erreichte Punktezahl
  def self.get_points_from_undeployed(undeployed, mono_last = false)
    # If all pieces were placed:
    if undeployed.empty?
      # Return sum of all squares plus 15 bonus points
      return SUM_MAX_SQUARES + 15 +
             # If the Monomino was the last placed piece, add another 5 points
             mono_last ? 5 : 0
    end
    # One point per block per piece placed
    SUM_MAX_SQUARES - undeployed.map(&:size).sum
  end

  # Return a random pentomino which is not the `x` one (Used to get a valid starting piece).
  def self.get_random_pentomino
    PieceShape.map(&:value).select {|it| it.size == 5 && it != PieceShape::PENTO_X }
  end

  # Führe den gegebenen [Move] im gebenenen [GameState] aus.
  # @param gamestate der aktuelle Spielstand
  # @param move der auszuführende Zug
  def self.perform_move(gamestate, move)
    validate_move_color(gamestate, move)
    case move
    when SkipMove
      perform_skip_move(gamestate)
    when SetMove
      perform_set_move(gamestate, move)
    end
    gamestate.lastMove = move
  end

  # Check if the given [move] has the right [Color].
  def self.validate_move_color(gamestate, move)
    if move.is_a?(SetMove.class) && move.piece.color != gamestate.current_color then
      raise InvalidMoveException.new("Expected move from #{gamestate.current_color}", move)
    end
  end

  # Check if the given [move] is able to be performed for the given [gamestate]. */
  def self.validate_set_move(gamestate, move)
    # Check whether the color's move is currently active
    validate_move_color(gamestate, move)
    # Check whether the shape is valid
    validate_shape(gamestate, move.piece.kind, move.piece.color)
    # Check whether the piece can be placed
    validate_set_move_placement(gamestate.board, move)

    if gamestate.is_first_move? then
      # Check if it is placed correctly in a corner
      if move.piece.coordinates.none? { |it| is_on_corner(it) } then
        raise InvalidMoveException.new("The Piece isn't located in a corner", move)
      end
    else
      # Check if the piece is connected to at least one tile of same color by corner
      if move.piece.coords.none? { |it| corners_on_color?(gamestate.board, it, move.piece.color) } then
        raise InvalidMoveException.new("#{move.piece} shares no corner with another piece of same color", move)
      end
    end

    true
  end

  # Perform the given [SetMove].
  def self.perform_set_move(gamestate, move)
    validate_set_move(gamestate, move)

    perform_set_move(gamestate.board, move)
    gamestate.undeployed_pieces(move.color).remove(move.piece.kind)
    gamestate.deployed_pieces(move.color).add(move.piece)

    # If it was the last piece for this color, remove it from the turn queue
    if gamestate.undeployed_piece_shapes(move.color).empty? then
      gamestate.lastMoveMono += move.color to (move.piece.kind == PieceShape.MONO)
      gamestate.remove_active_color
    end

    gamestate.try_advance()
  end

  # Validate the [PieceShape] of a [SetMove] depending on the current [GameState].
  def self.validate_shape(gamestate, shape, color = gamestate.current_color)
    if gamestate.is_first_move? then
      if shape != gamestate.start_piece then
        raise InvalidMoveException.new("#{shape} is not the requested first shape, #{gamestate.startPiece}")
      end
    else
      if !gamestate.undeployed_pieces(color).include? shape then
        raise InvalidMoveException.new("Piece #{shape} has already been placed before")
      end
    end
  end

  # Prüft, ob der gegebene [Move] zulässig ist.
  # @param gamestate der aktuelle Spielstand
  # @param move der zu überprüfende Zug
  #
  # @return ob der Zug zulässig ist
  def self.valid_set_move?(gamestate, move)
    begin
      validate_set_move(gamestate, move)
      true
    rescue InvalidMoveException
      false
    end
  end

  # Validate a [SetMove] on a [Board].
  def self.validate_set_move_placement(board, move)
    move.piece.coords.each do |it|
      if it.x < 0 || it.y < 0 || it.x >= BOARD_SIZE || it.y >= BOARD_SIZE then
        raise InvalidMoveException.new("Field #{it} is out of bounds", move)
      end

      if obstructed?(board, it)  then
        raise InvalidMoveException.new("Field #{it} already belongs to #{board[it].color}", move)
      end

      if borders_on_color?(board, it, move.piece.color) then
        raise InvalidMoveException.new("Field #{it} already borders on #{move.piece.color}", move)
      end
    end
  end

  # Place a Piece on the given [board] according to [move].
  def self.perform_set_move(board, move)
      move.piece.coordinates.each do |it|
          board[it] = move.color
      end
  end

  # Skip a turn.
  def self.perform_skip_move(gamestate)
    if first_move?(gamestate)
      raise InvalidMoveException.new("Can't Skip on first round", SkipMove.new(gamestate.currentColor))
    end
    if !gamestate.tryAdvance() then
      logger.error("Couldn't proceed to next turn!")
    end
  end

  # Check if the given [position] is already obstructed by another piece.
  def self.obstructed?(board, position)
    !board[position].color.nil?
  end

  # Check if the given [position] already borders on another piece of same [color].
  def self.borders_on_color?(board, position, color)
    [Coordinates.new(1, 0), Coordinates.new(0, 1), Coordinates.new(-1, 0), Coordinates.new(0, -1)].any? do |it|
      begin
        board[position + it].content == color
      rescue
        false
      end
    end
  end

  # Return true if the given [Coordinates] touch a corner of a field of same color.
  def self.corners_on_color?(board, position, color)
    [Coordinates.new(1, 1), Coordinates.new(1, -1), Coordinates.new(-1, -1), Coordinates.new(-1, 1)].any? do |it|
      begin
        board[position + it].color == color
      rescue
        false
      end
    end
  end

  # Return true if the given [Coordinates] are a corner.
  def self.corner?(position)
    corner = [
      Coordinates.new(0,0),
      Coordinates.new(BOARD_SIZE-1, 0),
      Coordinates.new(0, BOARD_SIZE-1),
      Coordinates.new(BOARD_SIZE-1, BOARD_SIZE-1)
    ]
    corner.include? position
  end

  # Gib zurück, ob sich der [GameState] noch in der ersten Runde befindet.
  def self.first_move?(gamestate)
    gamestate.undeployed_pieces(gamestate.current_color).length() == TOTAL_PIECE_SHAPES
  end

  # Return a list of all possible SetMoves, regardless of whether it's the first round.
  def self.get_all_possible_moves(gamestate)
    c = gamestate.current_color
    moves = []
    gamestate.undeployed_pieces(c).each do |p|
      Rotation.each do |r|
        [false, true].each do |f|
          (0..BOARD_SIZE-p.kind.dimension.x).to_a.each do |x|
            (0..BOARD_SIZE-p.kind.dimension.y).to_a.each do |y|
              moves << SetMove.new(Piece.new(c, p.kind, Coordinates.new(x, y), f, r))
            end
          end
        end
      end
    end
    moves.filter {|m| valid_set_move?(gamestate, m) }
  end

  # Return a list of all possible SetMoves, regardless of whether it's the first round.
  def self.get_possible_start_moves(gamestate)
    kind = gamestate.start_piece
    kind_max_x = BOARD_SIZE - kind.dimension.x
    kind_max_y = BOARD_SIZE - kind.dimension.y
    current_color = gamestate.current_color
    moves = []
    Rotation.each do |r|
      [false, true].each do |f|
        (0..kind_max_x).to_a.each do |x|
          (0..kind_max_y).to_a.each do |y|
            moves << SetMove.new(Piece.new(current_color, kind, Coordinates.new(x, y), f, r))
          end
        end
      end
    end
    moves.filter {|m| valid_set_move?(gamestate, m) }
  end

  # Return a list of all moves, impossible or not.
  # There's no real usage, except maybe for cases where no Move validation happens
  # if `Constants.VALIDATE_MOVE` is false, then this function should return the same
  # Set as `::getPossibleMoves`
  def self.get_all_moves()
    moves = []
    Color.each do |c|
      PieceShape.each do |s|
        Rotation.each do |r|
          [false, true].each do |f|
            (0..BOARD_SIZE-1).to_a.each do |x|
              (0..BOARD_SIZE-1).to_a.each do |y|
                moves << SetMove.new(Piece.new(c, s, Coordinates.new(x, y), f, r))
              end
            end
          end
        end
      end
    end
    moves
  end

  # Entferne alle Farben, die keine Steine mehr auf dem Feld platzieren können.
  def remove_invalid_colors(gamestate)
    return if gamestate.ordered_colors.empty?

    if get_possible_moves(gamestate).empty?
      gamestate.remove_active_color
      remove_invalid_colors(gamestate)
    end
  end

  # Prueft, ob ein Spielzug fuer den gegebenen Gamestate valide ist
  #
  # @param gamestate [Gamestate]
  # @param move [Move]
  # @return [?]
  def self.valid_move?(gamestate, move)
    case move
    when SetMove
      validate_set_move(gamestate, move)
    when SkipMove
      validate_skip_move(gamestate, move)
    end
  end

  def self.is_on_board(coords)
    coords.x >= 0 && coords.x < BOARD_SIZE && coords.y >= 0 && coords.y < BOARD_SIZE
  end

  def self.validate_skip_move(gamestate, move)
    unless possible_moves(gamestate).empty?
      raise InvalidMoveException.new('Skipping a turn is only allowed when no other moves can be made.', move)
    end
    if gamestate.round < 2
      raise InvalidMoveException.new('Skipping a turn is only allowed after the first turn', move)
    end
    true
  end

  def self.perform_move(gamestate, move)
    raise 'Invalid move!' unless valid_move?(gamestate, move)
    case move
    when SetMove
      gamestate.undeployed_pieces(move.piece.color).delete(move.piece)
      move.piece.coords.each do |coord|
        gamestate.board[coord].color = move.piece.color
      end
    end
    gamestate.turn += 1
    gamestate.last_move = move
  end

  # all possible moves, but will *not* return the skip move if no other moves are possible!
  # @param gamestate [GameState] Der zu untersuchende GameState.
  def self.possible_moves(gamestate)
    if (gamestate.turn > 1)
      possible_set_moves(gamestate) + SkipMove.new()
    else
      possible_set_moves(gamestate)
    end
  end

  # Gibt alle möglichen lege Züge zurück
  # @param gamestate [GameState] Der zu untersuchende GameState.
  def self.possible_set_moves(gamestate)
    if first_move?(gamestate) then
      get_possible_start_moves(gamestate)
    else
      get_all_possible_moves(gamestate)
    end
  end

  # Prueft, ob ein Spieler im gegebenen GameState gewonnen hat.
  # @param gamestate [GameState] Der zu untersuchende GameState.
  # @return [Condition] nil, if the game is not won or a Condition indicating the winning player
  def self.winning_condition(gamestate)
    raise 'Not implemented yet!'
  end
end
