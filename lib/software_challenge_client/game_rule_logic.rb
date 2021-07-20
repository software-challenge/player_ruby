# frozen_string_literal: true

require_relative './util/constants'
require_relative 'invalid_move_exception'
require_relative 'move'

require 'set'

# Methoden, welche die Spielregeln von Ostseeschach abbilden.
#
# Es gibt hier viele Helfermethoden, die von den beiden Hauptmethoden {GameRuleLogic#valid_move?}
# und {GameRuleLogic.possible_moves} benutzt werden.
class GameRuleLogic
  include Constants

  SUM_MAX_SQUARES = 89

  # --- Possible Moves ------------------------------------------------------------

  # Gibt alle möglichen Züge für den Spieler zurück, der in der gamestate dran ist.
  # Diese ist die wichtigste Methode dieser Klasse für Schüler.
  # @param gamestate [GameState] Der zu untersuchende Spielstand.
  #
  # @return [Array<Move>] Die möglichen Moves
  def self.possible_moves(gamestate)
    moves = []
    fields = gamestate.board.fields_of_color(gamestate.current_player.color)

    fields.each do |f|
      moves.push(*moves_for_piece(gamestate, f.piece))
    end

    moves.select { |m| valid_move?(gamestate, m) }.to_a
  end

  # Gibt einen zufälligen möglichen Zug zurück
  # @param gamestate [GameState] Der zu untersuchende Spielstand.
  #
  # @return [Move] Ein möglicher Move
  def self.possible_move(gamestate)
    possible_moves(gamestate).sample
  end

  # Hilfsmethode um Legezüge für einen [Piece] zu berechnen.
  # @param gamestate [GameState] Der zu untersuchende Spielstand.
  # @param piece [Piece] Der Typ des Spielsteines
  #
  # @return [Array<Move>] Die möglichen Moves
  def self.moves_for_piece(gamestate, piece)
    moves = Set[]
    piece.target_coords.each do |c| 
      moves << Move.new(piece.position, c)
    end
    moves.select { |m| valid_move?(gamestate, m) }.to_a
  end

  # --- Move Validation ------------------------------------------------------------

  # Prüft, ob der gegebene [Move] zulässig ist.
  # @param gamestate [GameState] Der zu untersuchende Spielstand.
  # @param move [Move] Der zu überprüfende Zug
  #
  # @return ob der Zug zulässig ist
  def self.valid_move?(gamestate, move)
    return false unless gamestate.current_player.color == move.piece(gamestate).color

    return false unless gamestate.board.in_bounds?(move.to)

    return false if gamestate.board.field_at(move.to).color == move.piece(gamestate).color

    return false unless move.piece(gamestate).target_coords.include? move.to

    # TODO 2022: Forgot checks?

    true
  end

  # Überprüft, ob die gegebene [position] mit einem Spielstein belegt ist.
  # @param board [Board] Das aktuelle Spielbrett
  # @param position [Coordinates] Die zu überprüfenden Koordinaten
  #
  # @return [Boolean] Ob die position belegt wurde
  def self.obstructed?(board, position)
    !board.field_at(position).empty?
  end

  # --- Perform Move ------------------------------------------------------------

  # Führe den gegebenen [Move] im gebenenen [GameState] aus.
  # @param gamestate [GameState] der aktuelle Spielstand
  # @param move der auszuführende Zug
  #
  # @return [GameState] Der theoretische GameState
  def self.perform_move(gamestate, move)
    raise 'Invalid move!' unless valid_move?(gamestate, move)

    from_field = gamestate.board.field_at(move.from)
    to_field = gamestate.board.field_at(move.to)

    # Update board pieces if one is stepped on
    if not to_field.empty?
      from_field.piece.height = from_field.piece.height + 1

      # Check for high tower
      if from_field.piece.height >= 3
        gamestate.current_player.amber = gamestate.current_player.amber + 1
        to_field.piece = nil
      end
    end
    
    # Update board fields
    to_field.piece = from_field.piece
    from_field.piece = nil

    gamestate.turn += 1
    gamestate.last_move = move
  end

  # --- Other ------------------------------------------------------------

  # Prueft, ob ein Spieler im gegebenen GameState gewonnen hat.
  # @param gamestate [GameState] Der zu untersuchende GameState.
  #
  # @return [Condition] nil, if the game is not won or a Condition indicating the winning player
  def self.winning_condition(gamestate)
    if gamestate.player_one.amber >= 2
      Condition.new(gamestate.player_one, "Spieler 1 hat 2 Bernsteine erreicht")
    end

    if gamestate.player_two.amber >= 2
      Condition.new(gamestate.player_two, "Spieler 2 hat 2 Bernsteine erreicht")
    end

    nil
  end
end
