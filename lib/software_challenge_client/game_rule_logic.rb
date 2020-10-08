# coding: utf-8
# frozen_string_literal: true

require_relative './util/constants'
require_relative 'invalid_move_exception'

# Methoden, welche die Spielregeln von Blokus abbilden.
#
# Es gibt hier viele Helfermethoden, die von den beiden Hauptmethoden {GameRuleLogic#valid_move?} und {GameRuleLogic.possible_moves} benutzt werden.
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
    PieceShape.filter do |it|
      it.size == 5 && it != PieceShape::PENTO_X
    end.sample
  end

  # Führe den gegebenen [Move] im gebenenen [GameState] aus.
  # @param gameState der aktuelle Spielstand
  # @param move der auszuführende Zug
  def perform_move(gamestate, move)
    validateMoveColor(gameState, move)
    case move
    when SkipMove
      performSkipMove(gameState)
    when SetMove
      performSetMove(gameState, move)
    end
    gameState.lastMove = move
  end

  # Check if the given [move] has the right [Color].
  def validate_move_color(gamestate, move)
    if move.color != gameState.currentColor
      raise InvalidMoveException('Expected move from #{gameState.current_color}', move)
    end
  end

  # Check if the given [move] is able to be performed for the given [gameState]. */
  def validate_set_move(gamestate, move)
    # Check whether the color's move is currently active
    validate_move_color(gamestate, move)
    # Check whether the shape is valid
    validate_shape(gamestate, move.piece.kind, move.color)
    # Check whether the piece can be placed
    validate_set_move(gamestate.board, move)

    if is_first_move(gamestate)
      # Check if it is placed correctly in a corner
      if move.piece.coordinates.none { |it| is_on_corner(it) }
        throw InvalidMoveException("The Piece isn't located in a corner", move)
      end
    else
      # Check if the piece is connected to at least one tile of same color by corner
      if move.piece.coordinates.none { |it| corners_on_color(gamestate.board, it, move.color) }
        throw InvalidMoveException("#{move.piece} shares no corner with another piece of same color", move)
      end
    end
  end

  # Perform the given [SetMove].
  def perform_set_move(gamestate, move)
    validate_set_move(gamestate, move)

    perform_set_move(gamestate.board, move)
    gameState.undeployed_pieces(move.color).remove(move.piece.kind)
    gameState.deployed_pieces(move.color).add(move.piece)

    # If it was the last piece for this color, remove it from the turn queue
    if gameState.undeployed_piece_shapes(move.color).empty?
      gameState.lastMoveMono += move.color to (move.piece.kind == PieceShape.MONO)
    end

    gameState.try_advance()
  end

  # Validate the [PieceShape] of a [SetMove] depending on the current [GameState].
  def validate_shape(gamestate, shape, color = gamestate.current_color)
    if (is_first_move(gamestate))
      if (shape != gamestate.start_piece)
        throw InvalidMoveException("$shape is not the requested first shape, ${gameState.startPiece}")
      end
    else
      if (!gameState.undeployedPieceShapes(color).contains(shape))
        throw InvalidMoveException("Piece $shape has already been placed before")
      end
    end
  end

  # Prüft, ob der gegebene [Move] zulässig ist.
  # @param gameState der aktuelle Spielstand
  # @param move der zu überprüfende Zug
  #
  # @return ob der Zug zulässig ist
  def is_valid_set_move(gamestate, move)
    begin
      validate_set_move(gameState, move)
      true
    rescue InvalidMoveException
      false
    end
  end

=begin
    # Validate a [SetMove] on a [board]. */
    def validate_set_move(board, move)
      move.piece.coordinates.each do |it|
            try {
                board[it]
            } catch (e: ArrayIndexOutOfBoundsException) {
                throw InvalidMoveException("Field $it is out of bounds", move)
            }
            // Checks if a part of the piece is obstructed
            if (isObstructed(board, it))
                throw InvalidMoveException("Field $it already belongs to ${board[it].content}", move)
            // Checks if a part of the piece would border on another piece of same color
            if (bordersOnColor(board, it, move.color))
                throw InvalidMoveException("Field $it already borders on ${move.color}", move)
        }
    }

    /** Place a Piece on the given [board] according to [move]. */
    @JvmStatic
    private fun performSetMove(board: Board, move: SetMove) {
        move.piece.coordinates.forEach {
            board[it] = +move.color
        }
    }

    /** Skip a turn. */
    @JvmStatic
    private fun performSkipMove(gameState: GameState) {
        if (!gameState.tryAdvance())
            logger.error("Couldn't proceed to next turn!")
        if (isFirstMove(gameState))
            throw InvalidMoveException("Can't Skip on first round", SkipMove(gameState.currentColor))
    }

    /** Check if the given [position] is already obstructed by another piece. */
    @JvmStatic
    private fun isObstructed(board: Board, position: Coordinates): Boolean =
            board[position].content != FieldContent.EMPTY

    /** Check if the given [position] already borders on another piece of same [color]. */
    @JvmStatic
    private fun bordersOnColor(board: Board, position: Coordinates, color: Color): Boolean = listOf(
            Vector(1, 0),
            Vector(0, 1),
            Vector(-1, 0),
            Vector(0, -1)).any {
        try {
            board[position + it].content == +color
        } catch (e: ArrayIndexOutOfBoundsException) { false }
    }

    /** Return true if the given [Coordinates] touch a corner of a field of same color. */
    @JvmStatic
    private fun cornersOnColor(board: Board, position: Coordinates, color: Color): Boolean = listOf(
            Vector(1, 1),
            Vector(1, -1),
            Vector(-1, -1),
            Vector(-1, 1)).any {
        try {
            board[position + it].content == +color
        } catch (e: ArrayIndexOutOfBoundsException) { false }
    }

    /** Return true if the given [Coordinates] are a corner. */
    @JvmStatic
    private fun isOnCorner(position: Coordinates): Boolean =
            Corner.asSet().contains(position)

    /** Gib zurück, ob sich der [GameState] noch in der ersten Runde befindet. */
    @JvmStatic
    fun isFirstMove(gameState: GameState) =
            gameState.undeployedPieceShapes(gameState.currentColor).size == Constants.TOTAL_PIECE_SHAPES


    /** Gib eine Sammlung an möglichen [SetMove]s zurück. */
    @JvmStatic
    fun getPossibleMoves(gameState: GameState) =
            streamPossibleMoves(gameState).toSet()

    /** Return a list of all possible SetMoves, regardless of whether it's the first round. */
    @JvmStatic
    private fun getAllPossibleMoves(gameState: GameState) =
            streamAllPossibleMoves(gameState).toSet()

    /** Return a list of possible SetMoves if it's the first round. */
    @JvmStatic
    private fun getPossibleStartMoves(gameState: GameState) =
            streamPossibleStartMoves(gameState).toSet()

    /**
     * Return a list of all moves, impossible or not.
     *  There's no real usage, except maybe for cases where no Move validation happens
     *  if `Constants.VALIDATE_MOVE` is false, then this function should return the same
     *  Set as `::getPossibleMoves`
     */
    @JvmStatic
    private fun getAllMoves(): Set<SetMove> {
        val moves = mutableSetOf<SetMove>()
        for (color in Color.values()) {
            for (shape in PieceShape.values()) {
                for (rotation in Rotation.values()) {
                    for (flip in listOf(false, true)) {
                        for (y in 0 until Constants.BOARD_SIZE) {
                            for (x in 0 until Constants.BOARD_SIZE) {
                                moves.add(SetMove(Piece(color, shape, rotation, flip, Coordinates(x, y))))
                            }
                        }
                    }
                }
            }
        }
        return moves
    }

    /** Entferne alle Farben, die keine Steine mehr auf dem Feld platzieren können. */
    @JvmStatic
    fun removeInvalidColors(gameState: GameState) {
        if (gameState.orderedColors.isEmpty()) return
        if (streamPossibleMoves(gameState).none { isValidSetMove(gameState, it) }) {
            gameState.removeActiveColor()
            removeInvalidColors(gameState)
        }
    }

    /** Gib Eine Sequenz an möglichen [SetMove]s zurück. */
    @JvmStatic
    fun streamPossibleMoves(gameState: GameState) =
            if (isFirstMove(gameState))
                streamPossibleStartMoves(gameState)
            else
                streamAllPossibleMoves(gameState)

    /** Stream all possible moves regardless of whether it's the first turn. */
    @JvmStatic
    private fun streamAllPossibleMoves(gameState: GameState) = sequence<SetMove> {
        val color = gameState.currentColor
        gameState.undeployedPieceShapes(color).map {
            val area = it.coordinates.area()
            for (y in 0 until Constants.BOARD_SIZE - area.dy)
                for (x in 0 until Constants.BOARD_SIZE - area.dx)
                    for (variant in it.variants) {
                        yield(SetMove(Piece(color, it, variant.key, Coordinates(x, y))))
                    }
        }
    }.filter { isValidSetMove(gameState, it) }

    /** Stream all possible moves if it's the first turn of [gameState]. */
    @JvmStatic
    private fun streamPossibleStartMoves(gameState: GameState) = sequence<SetMove> {
        val kind = gameState.startPiece
        for (variant in kind.variants) {
            for (corner in Corner.values()) {
                yield(SetMove(Piece(gameState.currentColor, kind, variant.key, corner.align(variant.key.area()))))
            }
        }
    }.filter { isValidSetMove(gameState, it) }


=end





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

  def self.validate_set_move(gamestate, move)
    owned_fields = gamestate.board.fields_of_color(gamestate.current_color)
    other_player_fields = gamestate.board.fields_of_color(gamestate.other_color)
    corner = false

    unless gamestate.undeployed_pieces(gamestate.current_player_color).include?(move.piece)
      raise InvalidMoveException.new('Piece is not a undeployed piece of the current player', move)
    end

    move.piece.shape.each { |coords|
      dest = Coordinates.new(coords.x + move.destination.x, coords.y + move.destination.y)
      unless is_on_board(dest)
        raise InvalidMoveException.new('Destination ${move.destination} is out of bounds!', move)
      end

      unless gamestate.board.field_at(dest).empty?
        raise InvalidMoveException.new('Set destination is not empty!', move)
      end

      unless other_player_fields.empty?
        if other_player_fields.map { |of| get_4neighbours(gamestate.board, of.coordinates).map(&:coordinates) }.flatten.include?(move.dest)
          raise InvalidMoveException.new('Piece can not touch other players pieces!', move)
        end
      end

      unless owned_fields.empty?
        if owned_fields.map { |of| get_4neighbours(gamestate.board, of.coordinates).map(&:coordinates) }.flatten.include?(move.dest)
          raise InvalidMoveException.new('Piece can not touch your already placed pieces!', move)
        end
      end

      if get_8neighbours(
           gamestate.board,
           move.destination
         ).any? {|f|
           f.color == gamestate.current_player_color &&
             get_4neighbours(gamestate.board, f).all? { |n| f.color == nil }
         }
        corner = true
      end
    }

    corner
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
      # delete first occurrence of piece
      gamestate.undeployed_pieces(move.piece.color).delete_at(
        gamestate.undeployed_pieces(move.piece.color).index(move.piece) ||
        gamestate.undeployed_pieces(move.piece.color).length
      )
      gamestate.board.field_at(move.destination).add_piece(move.piece)
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
    raise 'Not implemented yet!'
  end

  # Prueft, ob ein Spieler im gegebenen GameState gewonnen hat.
  # @param gamestate [GameState] Der zu untersuchende GameState.
  # @return [Condition] nil, if the game is not won or a Condition indicating the winning player
  def self.winning_condition(gamestate)
    raise 'Not implemented yet!'
  end
end
