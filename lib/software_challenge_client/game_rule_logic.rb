# coding: utf-8
# frozen_string_literal: true

require_relative './util/constants'
require_relative 'invalid_move_exception'

# Methoden, welche die Spielregeln von Blokus abbilden.
#
# Es gibt hier viele Helfermethoden, die von den beiden Hauptmethoden {GameRuleLogic#valid_move?} und {GameRuleLogic.possible_moves} benutzt werden.
class GameRuleLogic
  include Constants

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
    owned_fields = gamestate.board.fields_of_color(gamestate.current_player_color)
    other_player_fields = gamestate.board.fields_of_color(gamestate.other_player_color)
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

      if get_8neighbours(gamestate.board, move.destination).any? { |f| f.color == gamestate.current_player_color 
        && get_4neighbours(gamestate.board, f).all? { |n| f.color == nil } }
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
