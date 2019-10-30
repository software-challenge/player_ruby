# coding: utf-8
# frozen_string_literal: true

require_relative './util/constants'

# Methoden, welche die Spielregeln von Piranhas abbilden.
#
# Es gibt hier viele Helfermethoden, die von den beiden Hauptmethoden {GameRuleLogic#valid_move?} und {GameRuleLogic.possible_moves} benutzt werden.
class GameRuleLogic

  include Constants

  # Fügt einem leeren Spielfeld drei Brombeeren hinzu.
  #
  # Diese Methode ist dazu gedacht, ein initiales Spielbrett regelkonform zu generieren.
  #
  # @param board [Board] Das zu modifizierende Spielbrett. Es wird nicht
  #   geprüft, ob sich auf dem Spielbrett bereits Brombeeren befinden.
  # @return [Board] Das modifizierte Spielbrett.
  def self.add_blocked_fields(board)
    raise "todo"
    board
  end

  def self.get_neighbour_in_direction(board, coords, direction)
    board.field_at(direction.translate(coords))
  end

  def self.get_neighbours(board, coordinates)
    Direction.map { |d| get_neighbour_in_direction(board, coordinates, d) }.reject { |f| f.nil? }
  end

  def self.is_bee_blocked(board, color)
    bee_fields = board.field_list.select { |f| f.pieces.include?(Piece.new(color, PieceType::BEE)) }
    return false if bee_fields.empty?
    return get_neighbours(board, bee_fields[0].coordinates).all? { |f| f.obstructed || !f.empty? }
  end

  # Prueft, ob ein Spielzug fuer den gegebenen Gamestate valide ist
  #
  # @param gamestate [Gamestate]
  # @param move [Move]
  # @return [?]
  def self.valid_move?(gamestate, move)
    true # todo
  end

  def self.perform_move(gamestate, move)
    raise "Invalid move!" unless valid_move?(gamestate, move)
    case move
    when SetMove
      gamestate.undeployed_pieces(move.piece.color).remove(move.piece)
      gamestate.board.field_at(move.destination).add_piece(move.piece)
    when DragMove
      piece_to_move = gamestate.board.field_at(move.start).remove_piece
      gamestate.board.field_at(move.destination).add_piece(piece_to_move)
    end
    gamestate.turn += 1
    gamestate.last_move = move
  end

  # Prueft, ob ein Spieler im gegebenen GameState gewonnen hat.
  # @param gamestate [GameState] Der zu untersuchende GameState.
  # @return [Condition] nil, if the game is not won or a Condition indicating the winning player
  def self.winning_condition(gamestate)
    winner_by_single_swarm = [PlayerColor::RED, PlayerColor::BLUE].select do |player_color|
      GameRuleLogic.swarm_size(gamestate.board, player_color) ==
        gamestate.board.fields_of_type(PlayerColor.field_type(player_color)).size
    end
    if winner_by_single_swarm.any? && gamestate.turn.even?
      return Condition.new(nil, "Unentschieden.") if winner_by_single_swarm.size == 2
      return Condition.new(winner_by_single_swarm.first, "Schwarm wurde vereint.")
    end
    player_with_biggest_swarm = [PlayerColor::RED, PlayerColor::BLUE].sort_by do |player_color|
      GameRuleLogic.swarm_size(gamestate.board, player_color)
    end.reverse.first
    return Condition.new(player_with_biggest_swarm, "Rundenlimit erreicht, Schwarm mit den meisten Fischen gewinnt.") if gamestate.turn == 60
    nil
  end
end
