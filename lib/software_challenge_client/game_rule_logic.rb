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

  # --- Possible Moves ------------------------------------------------------------

  # all possible moves, but will *not* return the skip move if no other moves are possible!
  # @param gamestate [GameState] Der zu untersuchende GameState.
  def self.possible_moves(gamestate)
    re = possible_setmoves(gamestate)

    if not gamestate.is_first_move?
      re << SkipMove.new()
    end

    re
  end

  # Gibt alle möglichen lege Züge zurück
  # @param gamestate [GameState] Der zu untersuchende GameState.
  def self.possible_setmoves(gamestate)
    if gamestate.is_first_move? then
      get_possible_setmoves_for_kind(gamestate, gamestate.start_piece)
    else
      get_all_possible_moves(gamestate)
    end
  end

  # Return a list of all possible SetMoves, regardless of whether it's the first round.
  def self.get_all_possible_setmoves(gamestate)
    moves = []
    gamestate.undeployed_pieces(gamestate.current_color).each do |p|
      moves += get_possible_setmoves_for_kind(gamestate, p.kind)
    end
    moves
  end

  # Gibt eine Liste aller möglichen SetMoves für diese Form zurück.
  # @param gamestate der aktuelle Spielstand
  # @param kind die [PieceShape] der züge
  #
  # @return alle möglichen züge mit dem kind
  def self.get_possible_setmoves_for_kind(gamestate, kind)
    kind_max_x = BOARD_SIZE - kind.dimension.x
    kind_max_y = BOARD_SIZE - kind.dimension.y
    current_color = gamestate.current_color
    moves = []
    Rotation.each do |r|
      [false, true].each do |f|
        (0..kind_max_x).to_a.each do |x|
          (0..kind_max_y).to_a.each do |y|
            moves << SetMove.new(Piece.new(current_color, kind, r, f, Coordinates.new(x, y)))
          end
        end
      end
    end
    moves.filter {|m| valid_set_move?(gamestate, m) }
  end

  # # Return a list of all moves, impossible or not.
  # # There's no real usage, except maybe for cases where no Move validation happens
  # # if `Constants.VALIDATE_MOVE` is false, then this function should return the same
  # # Set as `::getPossibleMoves`
  # def self.get_all_set_moves()
  #   moves = []
  #   Color.each do |c|
  #     PieceShape.each do |s|
  #       Rotation.each do |r|
  #         [false, true].each do |f|
  #           (0..BOARD_SIZE-1).to_a.each do |x|
  #             (0..BOARD_SIZE-1).to_a.each do |y|
  #               moves << SetMove.new(Piece.new(c, s, r, f, Coordinates.new(x, y)))
  #             end
  #           end
  #         end
  #       end
  #     end
  #   end
  #   moves
  # end

  # --- Move Validation ------------------------------------------------------------

  # Prüft, ob der gegebene [Move] zulässig ist.
  # @param gamestate der aktuelle Spielstand
  # @param move der zu überprüfende Zug
  #
  # @return ob der Zug zulässig ist
  def self.valid_move?(gamestate, move)
    if move.instance_of? SkipMove
      !gamestate.is_first_move?
    else
      valid_set_move?(gamestate, move)
    end
  end

  # Prüft, ob der gegebene [SetMove] zulässig ist.
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
      if move.piece.coords.none? { |it| corner?(it) } then
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

  # Check if the given [move] has the right [Color].
  def self.validate_move_color(gamestate, move)
    if move.is_a?(SetMove.class) && move.piece.color != gamestate.current_color then
      raise InvalidMoveException.new("Expected move from #{gamestate.current_color}", move)
    end
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

  # Check if the given [position] is already obstructed by another piece.
  def self.obstructed?(board, position)
    !board[position].color.nil?
  end

  # --- Perform Move ------------------------------------------------------------

  # Führe den gegebenen [Move] im gebenenen [GameState] aus.
  # @param gamestate der aktuelle Spielstand
  # @param move der auszuführende Zug
  def self.perform_move(gamestate, move)
    raise 'Invalid move!' unless valid_move?(gamestate, move)
    if move.instance_of? SetMove
      gamestate.undeployed_pieces(move.piece.color).delete(move.piece)
      # gamestate.deployed_pieces(move.piece.color).add(move.piece)

      # Apply piece to board
      move.piece.coords.each do |coord|
        gamestate.board[coord].color = move.piece.color
      end

      # If it was the last piece for this color, remove it from the turn queue
      if gamestate.undeployed_pieces(move.piece.color).empty? then
        gamestate.lastMoveMono += move.color to (move.piece.kind == PieceShape.MONO)
        gamestate.remove_active_color
      end
    end
    gamestate.turn += 1
    gamestate.round += 1
    gamestate.last_move = move
  end

  # --- Other ------------------------------------------------------------

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

  # Entferne alle Farben, die keine Steine mehr auf dem Feld platzieren können.
  def remove_invalid_colors(gamestate)
    return if gamestate.ordered_colors.empty?

    if get_possible_moves(gamestate).empty?
      gamestate.remove_active_color
      remove_invalid_colors(gamestate)
    end
  end

  # Prueft, ob ein Spieler im gegebenen GameState gewonnen hat.
  # @param gamestate [GameState] Der zu untersuchende GameState.
  # @return [Condition] nil, if the game is not won or a Condition indicating the winning player
  def self.winning_condition(gamestate)
    raise 'Not implemented yet!'
  end
end
