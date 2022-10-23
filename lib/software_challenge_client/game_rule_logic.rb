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
    if gamestate.turn < 8
      self.possible_setmoves(gamestate)
    else
      self.possible_normalmoves(gamestate)
    end
  end

  # Gibt alle möglichen Lege-Züge für den Spieler zurück, der in der gamestate dran ist.
  # @param gamestate [GameState] Der zu untersuchende Spielstand.
  #
  # @return [Array<Move>] Die möglichen Moves
  def self.possible_setmoves(gamestate)
    moves = []

    (0...BOARD_SIZE).to_a.map do |x|
      (0...BOARD_SIZE).to_a.map do |y|
        if gamestate.board.field(x, y).fishes == 1
          moves.push(Move.new(nil, Coordinates.new(x, y)))
        end
      end
    end

    moves
  end

  def self.possible_normalmoves(gamestate)
    moves = []
    fields = gamestate.board.fields_of_team(gamestate.current_player.team)

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
    self.possible_moves(gamestate).sample
  end

  # Hilfsmethode um Legezüge für einen [Piece] zu berechnen.
  # @param gamestate [GameState] Der zu untersuchende Spielstand.
  # @param piece [Piece] Der Typ des Spielsteines
  #
  # @return [Array<Move>] Die möglichen Moves
  def self.moves_for_piece(gamestate, piece)
    moves = Set[]
    self.target_coords(gamestate, piece).each do |c| 
      moves << Move.new(piece.coords, c)
    end
    moves.select { |m| valid_move?(gamestate, m) }.to_a
  end

  # Berechnet die Koordinaten zu denen sich dieser Spielstein bewegen könnte.
  #
  # @return [Array<Coordinates>] Die Zielkoordinaten 
  def self.target_coords(gamestate, piece)
    coords = []
    c = Coordinates.oddr_to_doubled(piece.coords)

    Direction.each { |d|
      x = c.x
      y = c.y
      disp = d.to_vec()

      # doubled taversal
      for i in 0..8 do
        x += disp.x
        y += disp.y
        
        oddr_coords = Coordinates.doubled_to_oddr_int(x, y)
        if !gamestate.board.in_bounds?(oddr_coords) || !gamestate.board.field_at(oddr_coords).free?
          break
        end

        coords.push(oddr_coords)
      end
    }

    coords
  end

  # --- Move Validation ------------------------------------------------------------

  # Prüft, ob der gegebene [Move] zulässig ist.
  # @param gamestate [GameState] Der zu untersuchende Spielstand.
  # @param move [Move] Der zu überprüfende Zug
  #
  # @return ob der Zug zulässig ist
  def self.valid_move?(gamestate, move)
    if gamestate.turn < 8
      # Setmove

      # Must be setmove
      return false unless move.from == nil
      
      # Must have 1 fish to set on
      return false unless gamestate.board.field_at(move.to).fishes == 1 

      # Must have no piece on it
      return false unless gamestate.board.field_at(move.to).piece == nil
    else
      # Normal move

      # Must be normal move
      return false unless !move.from.nil?

      # Team must be correct
      return false unless gamestate.current_player.team == gamestate.board.field_at(move.from).piece.team

      # Move must stay in bounds
      return false unless gamestate.board.in_bounds?(move.to)

      # Move must go onto free field
      return false unless gamestate.board.field_at(move.to).free?

      # Move must go onto valid coords
      return false unless self.target_coords(gamestate, gamestate.board.field_at(move.from).piece).include?(move.to)
    end

    # TODO 2023: Forgot checks?

    true
  end

  # --- Perform Move ------------------------------------------------------------

  # Führe den gegebenen [Move] im gebenenen [GameState] aus.
  # @param gamestate [GameState] der aktuelle Spielstand
  # @param move der auszuführende Zug
  #
  # @return [GameState] Der theoretische GameState
  def self.perform_move(gamestate, move)
    raise 'Invalid move!' unless valid_move?(gamestate, move)

    target_field = gamestate.board.field_at(move.to)

    gamestate.current_player.fishes += target_field.fishes

    if gamestate.turn < 8 
      target_field.piece = Piece.new(gamestate.current_player.team, move.to)
    else
      start_field = gamestate.board.field_at(move.from)

      start_field.fishes = 0

      target_field.piece = start_field.piece
      start_field.piece = nil?
    end

    other_player = gamestate.not_player(gamestate.current_player)
    if gamestate.can_move?(other_player)
      gamestate.current_player = other_player
    end

    gamestate.turn += 1
  end

  # --- Other ------------------------------------------------------------

  # Prueft, ob ein Spieler im gegebenen GameState gewonnen hat.
  # @param gamestate [GameState] Der zu untersuchende GameState.
  #
  # @return [Condition] nil, if the game is not won or a Condition indicating the winning player
  def self.winning_condition(gamestate)
    
    if GameRuleLogic.possible_moves(gamestate).count == 0
      if gamestate.player_one.fishes > gamestate.player_two.fishes
        Condition.new(gamestate.player_one, "Spieler 1 hat mehr Fische erreicht und gewonnen!")
      else
        Condition.new(gamestate.player_one, "Spieler 2 hat mehr Fische erreicht und gewonnen!")
      end
    end

    nil
  end
end
