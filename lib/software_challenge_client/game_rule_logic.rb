# coding: utf-8
# frozen_string_literal: true

require_relative './util/constants'
require_relative 'invalid_move_exception'

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
    Direction.map { |d| get_neighbour_in_direction(board, coordinates, d) }.compact
  end

  def self.is_bee_blocked(board, color)
    bee_fields = board.field_list.select { |f| f.pieces.include?(Piece.new(color, PieceType::BEE)) }
    return false if bee_fields.empty?
    return get_neighbours(board, bee_fields[0].coordinates).all? { |f| !f.empty? }
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
    when DragMove
      validate_drag_move(gamestate, move)
    when SkipMove
      validate_skip_move(gamestate, move)
    end
  end

  def self.validate_drag_move(gamestate, move)
    true # todo
  end

  def self.is_on_board(coords)
    shift = (BOARD_SIZE - 1) / 2
    -shift <= coords.x && coords.x <= shift && -shift <= coords.y && coords.y <= shift
  end

  def self.has_player_placed_bee(gamestate)
    gamestate.deployed_pieces(gamestate.current_player_color).any? { |p| p.type == PieceType::BEE }
  end

  def self.validate_set_move(gamestate, move)
    unless is_on_board(move.destination)
      raise InvalidMoveException.new("Piece has to be placed on board. Destination ${move.destination} is out of bounds.", move)
    end
    unless gamestate.board.field_at(move.destination).empty?
      raise InvalidMoveException.new("Set destination is not empty!", move)
    end

    owned_fields = gamestate.board.fields_of_color(gamestate.current_player_color)
    if owned_fields.empty?
      other_player_fields = gamestate.board.fields_of_color(gamestate.other_player_color)
      if !other_player_fields.empty?
        unless other_player_fields.map{ |of| get_neighbours(gamestate.board, of.coordinates).map{ |n| n.coordinates } }.flatten.include?(move.destination)
          raise InvalidMoveException.new("Piece has to be placed next to other players piece", move)
        end
      end
    else
      if gamestate.round == 3 && !has_player_placed_bee(gamestate) && move.piece.type != PieceType::BEE
        raise InvalidMoveException.new("The bee must be placed in fourth round latest", move)
      end

      if !gamestate.undeployed_pieces(gamestate.current_player_color).include?(move.piece)
        raise InvalidMoveException.new("Piece is not a undeployed piece of the current player", move)
      end

      destination_neighbours = get_neighbours(gamestate.board, move.destination)
      if !destination_neighbours.any? { |f| f.color == gamestate.current_player_color }
        raise InvalidMoveException.new("A newly placed piece must touch an own piece", move)
      end
      if destination_neighbours.any? { |f| f.color == gamestate.other_player_color }
        raise InvalidMoveException.new("A newly placed is not allowed to touch an opponent's piece", move)
      end
    end
    true
  end

  def self.validate_skip_move(gamestate, move)
    if !possible_moves(gamestate).empty?
      raise InvalidMoveException.new("Skipping a turn is only allowed when no other moves can be made.", move)
    end
    if gamestate.round == 3 && !has_player_placed_bee(gamestate)
      raise InvalidMoveException.new("The bee must be placed in fourth round latest", move)
    end
    true
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

  # all possible moves, but will *not* return the skip move if no other moves are possible!
  def self.possible_moves(gamestate)
    possible_set_moves(gamestate) + possible_drag_moves(gamestate)
  end

  def self.possible_drag_moves(gamestate)
    gamestate.board.fields_of_color(gamestate.current_player_color).flat_map do |start_field|
      edge_targets = empty_fields_connected_to_swarm(gamestate.board)
      additional_targets =
        if start_field.pieces.last.type == PieceType::BEETLE
          get_neighbours(gamestate.board, start_field).uniq
        else
          []
        end
      edge_targets + additional_targets.map do |destination|
        move = DragMove.new(start_field, destination)
        begin
          valid_move?(gamestate, move)
          move
        rescue InvalidMoveException
          null
        end
      end.compact
    end
  end

  def self.empty_fields_connected_to_swarm(board)
    board.field_list
      .filter { |f| f.has_owner }
      .flat_map { |f| get_neighbours(board, f).filter { f.empty? } }
      .uniq
  end

  def self.possible_set_move_destinations(board, owner)
    board.fields_of_color(owner)
      .flat_map { |f| get_neighbours(board, f).filter { |f| f.empty? } }
      .uniq
      .filter { |f| get_neighbours(board, f).all? { |n| n.color != owner.opponent } }
  end

  def self.possible_set_moves(gamestate)
    undeployed = gamestate.undeployed_pieces(gamestate.current_player_color)
    set_destinations =
      if (undeployed.size == STARTING_PIECES.size)
        # current player has not placed any pieces yet (first or second turn)
        if (gamestate.undeployed_pieces(gamestate.other_player_color).size == STARTING_PIECES.size)
          # other player also has not placed any pieces yet (first turn, all destinations allowed (except obstructed)
          gamestate.board.field_list.filter { |f| f.empty? }
        else
          # other player placed a piece already
          gamestate.board
            .fields_of_color(gamestate.other_player_color)
            .flat_map do |f|
              GameRuleLogic.get_neighbours(gamestate.board, f).filter(&:empty?)
            end
        end
      else
        possible_set_move_destinations(gamestate.board, gamestate.current_player_color)
      end

    possible_piece_types =
      if (!has_player_placed_bee(gamestate) && gamestate.turn > 5)
        [PieceType::BEE]
      else
        undeployed.map(&:type).uniq
      end
    set_destinations
      .flat_map do |d|
        possible_piece_types.map do |u|
          SetMove.new(Piece.new(gamestate.current_player_color, u), d)
        end
    end
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
