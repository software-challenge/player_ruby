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

  def self.validate_drag_move(gamestate, move)
    unless has_player_placed_bee(gamestate)
      raise InvalidMoveException.new("You have to place the bee to be able to perform dragmoves", move)
    end

    if (!is_on_board(move.destination) || !is_on_board(move.start))
      raise InvalidMoveException.new("The Move is out of bounds", move)
    end

    if (gamestate.board.field_at(move.start).pieces.empty?)
      raise InvalidMoveException.new("There is no piece to move", move)
    end

    piece_to_drag = gamestate.board.field_at(move.start).pieces.last

    if (piece_to_drag.owner != gamestate.current_player_color)
      raise InvalidMoveException.new("Trying to move piece of the other player", move)
    end

    if (move.start == move.destination)
      raise InvalidMoveException.new("Destination and start are equal", move)
    end

    if (!gamestate.board.field_at(move.destination).pieces.empty? && piece_to_drag.type != PieceType::BEETLE)
      raise InvalidMoveException.new("Only beetles are allowed to climb on other Pieces", move)
    end

    board_without_piece = gamestate.board.clone
    board_without_piece.field_at(move.start).pieces.pop

    if (!is_swarm_connected(board_without_piece))
      raise InvalidMoveException.new("Moving piece would disconnect swarm", move)
    end

    case piece_to_drag.type
    when PieceType::ANT
      validate_ant_move(board_without_piece, move)
    when PieceType::BEE
      validate_bee_move(board_without_piece, move)
    when PieceType::BEETLE
      validate_beetle_move(board_without_piece, move)
    when PieceType::GRASSHOPPER
      validate_grasshopper_move(board_without_piece, move)
    when PieceType::SPIDER
      validate_spider_move(board_without_piece, move)
    end
    true
  end

  def self.validate_ant_move(board, move)
    visited_fields = [move.start]
    index = 0
    while index < visited_fields.size
      current_field = visited_fields[index]
      new_fields = accessible_neighbours_except(board, current_field, move.start).reject { |f| visited_fields.include? f }
      return true if new_fields.map(&:coordinates).include?(move.destination)
      visited_fields += new_fields
      index += 1
    end
    raise InvalidMoveException.new("No path found for ant move", move)
  end

  def self.is_swarm_connected(board)
    board_fields = board.field_list.select{ |f| !f.pieces.empty? }
    return true if board_fields.empty?
    visited_fields = board_fields.take 1
    total_pieces = board.pieces.size
    index = 0
    while index < visited_fields.size
      current_field = visited_fields[index]
      occupied_neighbours =
        get_neighbours(board, current_field.coordinates)
          .filter { |f| !f.pieces.empty? }
      occupied_neighbours -= visited_fields
      visited_fields += occupied_neighbours
      return true if visited_fields.sum{ |f| f.pieces.size } == total_pieces
      index += 1
    end
    false
  end

  def self.validate_beetle_move(board, move)
    validate_destination_next_to_start(move)
    if ((shared_neighbours_of_two_coords(board, move.start, move.destination) + [board.field_at(move.destination), board.field_at(move.start)]).all? { |f| f.pieces.empty? })
      raise InvalidMoveException.new("Beetle has to move along swarm", move)
    end
  end

  def self.validate_destination_next_to_start(move)
    if (!is_neighbour(move.start, move.destination))
      raise InvalidMoveException.new("Destination field is not next to start field", move)
    end
  end

  def self.is_neighbour(start, destination)
    Direction.map do |d|
      d.translate(start)
    end.include?(destination)
  end

  def self.shared_neighbours_of_two_coords(board, first_coords, second_coords)
    get_neighbours(board, first_coords) & get_neighbours(board, second_coords)
  end

  def self.validate_bee_move(board, move)
    validate_destination_next_to_start(move)
    if (!can_move_between(board, move.start, move.destination))
      raise InvalidMoveException.new("There is no path to your destination", move)
    end
  end

  def self.can_move_between(board, coords1, coords2)
    shared = shared_neighbours_of_two_coords(board, coords1, coords2)
    (shared.size == 1 || shared.any? { |n| n.empty? && !n.obstructed }) && shared.any? { |n| !n.pieces.empty? }
  end

  def self.validate_grasshopper_move(board, move)
    if (!two_fields_on_one_straight(move.start, move.destination))
      raise InvalidMoveException.new("Grasshopper can only move straight lines", move)
    end
    if (is_neighbour(move.start, move.destination))
      raise InvalidMoveException.new("Grasshopper has to jump over at least one piece", move)
    end
    if (get_line_between_coords(board, move.start, move.destination).any? { |f| f.empty? })
      raise InvalidMoveException.new("Grasshopper can only jump over occupied fields, not empty ones", move)
    end
  end

  def self.two_fields_on_one_straight(coords1, coords2)
    return coords1.x == coords2.x || coords1.y == coords2.y || coords1.z == coords2.z
  end

  def self.get_line_between_coords(board, start, destination)
    if (!two_fields_on_one_straight(start, destination))
      raise InvalidMoveException.new("destination is not in line with start")
    end

    # TODO use Direction shift
    dX = start.x - destination.x
    dY = start.y - destination.y
    dZ = start.z - destination.z
    d = (dX == 0) ? dY.abs : dX.abs
    (1..(d-1)).to_a.map do |i|
      board.field_at(
        CubeCoordinates.new(
          destination.x + i * (dX <=> 0),
          destination.y + i * (dY <=> 0),
          destination.z + i * (dZ <=> 0)
        )
      )
    end
  end
  def self.accessible_neighbours_except(board, start, except)
    get_neighbours(board, start).filter do |neighbour|
      neighbour.empty? && can_move_between_except(board, start, neighbour, except) && neighbour.coordinates != except
    end
  end

  def self.can_move_between_except(board, coords1, coords2, except)
    shared = shared_neighbours_of_two_coords(board, coords1, coords2).reject do |f|
      f.pieces.size == 1 && except == f.coordinates
    end
    (shared.size == 1 || shared.any? { |s| s.empty? && !s.obstructed }) && shared.any? { |s| !s.pieces.empty? }
  end

  def self.validate_spider_move(board, move)
    found = get_accessible_neighbours(board, move.start).any? do |depth_one|
      get_accessible_neighbours_except(board, depth_one, move.start).any? do |depth_two|
        get_accessible_neighbours_except(board, depth_two, move.start).reject{ |f| f.coordinates == depth_one.coordinates }.any? { |f| move.destination == f.coordinates }
      end
    end
    return true if (found)
    raise InvalidMoveException.new("No path found for spider move", move)
  end

  def self.get_accessible_neighbours(board, start)
    get_neighbours(board, start).filter do |neighbour|
      neighbour.empty? && can_move_between(board, start, neighbour)
    end
  end

  def self.get_accessible_neighbours_except(board, start, except)
    get_neighbours(board, start).filter do |neighbour|
      neighbour.empty? &&
        can_move_between_except(board, start, neighbour, except) &&
        neighbour.coordinates != except
    end
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
