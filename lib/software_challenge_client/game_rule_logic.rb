# coding: utf-8
# frozen_string_literal: true

require_relative './util/constants'
require_relative 'invalid_move_exception'
require_relative 'set_move'

require 'set'

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

    re << SkipMove.new unless gamestate.is_first_move?

    re
  end

  # Returns one possible move
  # @param gamestate [GameState] Der zu untersuchende GameState.
  def self.possible_move(gamestate)
    current_color = gamestate.current_color
    for p in gamestate.undeployed_pieces(current_color) do
      kind_max_x = BOARD_SIZE - p.dimension.x
      kind_max_y = BOARD_SIZE - p.dimension.y
      for r in Rotation.to_a do
        for f in [true,false] do
          for x in 0..kind_max_x do
            for y in 0..kind_max_y do
              move = SetMove.new(Piece.new(current_color, p, r, f, Coordinates.new(x, y)))
              return move if valid_set_move?(gamestate, move)
            end
          end
        end
      end
    end

    SkipMove.new
  end

  # Gibt alle möglichen lege Züge zurück
  # @param gamestate [GameState] Der zu untersuchende GameState.
  def self.possible_setmoves(gamestate)
    if gamestate.is_first_move? then
      get_possible_setmoves_for_kind(gamestate, gamestate.start_piece)
    else
      get_all_possible_setmoves(gamestate)
    end
  end

  # Return a list of all possible SetMoves, regardless of whether it's the first round.
  def self.get_all_possible_setmoves(gamestate)
    current_color = gamestate.current_color
    moves = []
    gamestate.undeployed_pieces(current_color).each do |p|
      moves += get_possible_setmoves_for_kind(gamestate, p)
    end
    moves
  end

  # Gibt eine Liste aller möglichen SetMoves für diese Form zurück.
  # @param gamestate der aktuelle Spielstand
  # @param kind die [PieceShape] der züge
  #
  # @return alle möglichen züge mit dem kind
  def self.get_possible_setmoves_for_kind(gamestate, kind)
    current_color = gamestate.current_color
    moves = []
    fields = Set[]
    get_valid_fields(gamestate).each do |p|
      (p.x - 5..p.x).each do |x|
        (p.y - 5..p.y).each do |y|
          fields.add(Coordinates.new(x, y))
        end
      end
    end

    Rotation.to_a.each do |r|
      [false, true].each do |f|
        fields.each do |p|
          moves << SetMove.new(Piece.new(current_color, kind, r, f, p))
        end
      end
    end
    moves.filter { |m| valid_set_move?(gamestate, m) }
  end

  def self.get_valid_fields(gamestate)
    color = gamestate.current_color
    board = gamestate.board
    [Coordinates.new(0, 0), Coordinates.new(0, Constants::BOARD_SIZE), Coordinates.new(Constants::BOARD_SIZE, Constants::BOARD_SIZE), Coordinates.new(Constants::BOARD_SIZE, 0)].each do |f|
      unless board[f].nil?
        return get_valid_fields_around(gamestate, f) if board[f].color == color
      end
    end
  end

  def self.get_valid_fields_around(gamestate, field)
    if gamestate.board[field].color == gamestate.current_color
      field.coords
    else
      fields = Set[]
      [Coordinates.new(-1, -1), Coordinates.new(-1, 0), Coordinates.new(-1, 1), Coordinates.new(0, 1), Coordinates.new(1, 1), Coordinates.new(1, 0), Coordinates.new(1, -1), Coordinates.new(0, -1)].each do |n|
        neighbour = field.coords + n
        if neighbour.x >= 0 && neighbour.x < Constants::BOARD_SIZE && neighbour.y >= 0 && neighbour.y < Constants::BOARD_SIZE
          if gamestate.board[neighbour].color == gamestate.current_color
            fields.merge(get_valid_fields_around(gamestate, neighbour))
          elsif gamestate.board[neighbour].color.nil?
            fields.add(neighbour)
          end
        end
      end
      fields
    end
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
    # Check whether the color's move is currently active
    return false if move.piece.color != gamestate.current_color

    # Check whether the shape is valid
    if gamestate.is_first_move?
      return false if move.piece.kind != gamestate.start_piece
    elsif !gamestate.undeployed_pieces(move.piece.color).include?(move.piece.kind)
      return false
    end

    # Check whether the piece can be placed
    move.piece.coords.each do |it|
      return false unless gamestate.board.in_bounds?(it)
      return false if obstructed?(gamestate.board, it)
      return false if borders_on_color?(gamestate.board, it, move.piece.color)
    end

    if gamestate.is_first_move?
      # Check if it is placed correctly in a corner
      return false if move.piece.coords.none? { |it| corner?(it) }
    else
      # Check if the piece is connected to at least one tile of same color by corner
      return false if move.piece.coords.none? { |it| corners_on_color?(gamestate.board, it, move.piece.color) }
    end

    true
  end

  # Check if the given [position] already borders on another piece of same [color].
  def self.borders_on_color?(board, position, color)
    [Coordinates.new(1, 0), Coordinates.new(0, 1), Coordinates.new(-1, 0), Coordinates.new(0, -1)].any? do |it|
      if board.in_bounds?(position + it)
        board[position + it].color == color
      else
        false
      end
    end
  end

  # Return true if the given [Coordinates] touch a corner of a field of same color.
  def self.corners_on_color?(board, position, color)
    [Coordinates.new(1, 1), Coordinates.new(1, -1), Coordinates.new(-1, -1), Coordinates.new(-1, 1)].any? do |it|
      board.in_bounds?(position + it) && board[position + it].color == color
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
    PieceShape.map(&:value).select { |it| it.size == 5 && it != PieceShape::PENTO_X }
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
