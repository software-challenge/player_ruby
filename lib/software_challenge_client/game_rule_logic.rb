# coding: utf-8
# frozen_string_literal: true

require_relative 'field_type'
require_relative 'line'
require_relative './util/constants'

# All methods which define the game rules. Needed for checking validity of moves
# and performing them.
class GameRuleLogic

  include Constants

  def self.add_blocked_fields(board)
    number_of_blocked_fields = 2
    lower_bound = 2 # first row or column, in which blocked fields are allowed
    upper_bound = 7 # last row or column, in which blocked fields are allowed

    # create a list of coordinates for fields which may be blocked
    blockable_field_coordinates = (lower_bound..upper_bound).to_a.map do |x|
      (lower_bound..upper_bound).to_a.map do |y|
        Coordinate.new(x, y)
      end
    end.flatten

    # set fields with randomly selected coordinates to blocked coordinates may
    # not lay on same horizontal, vertical or diagonal lines with other selected
    # coordinates
    number_of_blocked_fields.times do
      selected_coords = blockable_field_coordinates.sample
      board.change_field(selectedCoords, FieldType::OBSTRUCTED)
      # remove field coordinates and fields on horizontal, vertical and diagonal
      # lines:
      coordinates_to_remove = ALL_DIRECTIONS.map do |direction|
        Line.new(selected_coords, direction).to_a
      end.flatten
      blockable_field_coordinates = blockable_field_coordinates.filter do |c|
        coordinates_to_remove.none? do |to_remove|
          c.x == to_remove.x && c.y == to_remove.y
        end
      end
    end
    board
  end

  def self.count_fish(board, start, direction)
    # filter function for fish field type
    fish = proc { |f| f.type == FieldType::RED || f.type == FieldType::BLUE }
    Line.new(start, direction).to_a.map do |p|
      board.field(p.x, p.y)
    end.select(&fish).size
  end

  def self.player_field_type(color)
    case color
    when PlayerColor::RED
      FieldType::RED
    when PlayerColor::BLUE
      FieldType::BLUE
    end
  end

  def self.field_type_player(_field_type)
    case fiel_type
    when FieldType::RED
      PlayerColor::RED
    when FieldType::BLUE
      PlayerColor::BLUE
    end
  end

  def self.target_coordinates(move, board)
    speed = GameRuleLogic.count_fish(
      board, move.from_field,
      Line.line_direction_for_direction(move.direction)
    )
    move.target_field(speed)
  end

  def self.move_target(move, board)
    c = GameRuleLogic.target_coordinates(move, board)
    board.field(c.x, c.y)
  end

  def self.inside_bounds?(coordinates)
    coordinates.x >= 0 &&
      coordinates.x < SIZE &&
      coordinates.y >= 0 &&
      coordinates.y < SIZE
  end

  def self.obstacle?(field_type, moving_player_color)
    field_type == GameRuleLogic.player_field_type(
      PlayerColor.opponent_color(moving_player_color)
    )
  end

  def self.no_obstacle?(from_field, direction, to_field, color, board)
    Line.new(from_field, direction)
        .to_a
        .select { |c| Line.between(from_field, to_field, direction).call(c) }
        .none? { |f| GameRuleLogic.obstacle?(board.field(f.x, f.y).type, color) }
  end

  def self.valid_move_target(target, moving_player_color, board)
    target_field_type = board.field(target.x, target.y).type
    target_field_type == FieldType::EMPTY ||
      target_field_type == GameRuleLogic.player_field_type(
        PlayerColor.opponent_color(moving_player_color)
      )
  end

  def self.valid_move?(move, board, current_player_color)
    from_field_type = board.field(move.x, move.y).type
    return false unless
      [FieldType::BLUE, FieldType::RED].include? from_field_type
    return false unless
      current_player_color == FieldType.player_color(from_field_type)

    return false unless
      GameRuleLogic.inside_bounds?(
        GameRuleLogic.target_coordinates(move, board)
      )

    target = GameRuleLogic.move_target(move, board)

    GameRuleLogic.valid_move_target(target, current_player_color, board) &&
      GameRuleLogic.no_obstacle?(
        move.from_field,
        Line.line_direction_for_direction(move.direction),
        target, current_player_color, board
      )
  end

  def self.possible_moves(board, field, current_player_color)
    Direction.map { |direction| Move.new(field.x, field.y, direction) }
             .select do |m|
               GameRuleLogic.valid_move?(m, board, current_player_color)
             end
  end

  def self.swarm_size(board, player_color)
    GameRuleLogic.greatest_swarm_from_fields(
      board,
      board.fields_of_type(
        PlayerColor.field_type(player_color)
      ).to_set,
      Set.new
    ).size
  end

  def self.neighbours(board, field)
    Direction
      .map { |d| d.translate(field.coordinates) }
      .select { |c| GameRuleLogic.inside_bounds?(c) }
      .map { |c| board.field_at(c) }
  end

  def self.greatest_swarm_from_fields(board, fields_to_check, current_biggest_swarm)
    # stop searching when the size of the current found biggest set is bigger than the rest of the fields
    return current_biggest_swarm if current_biggest_swarm.size > fields_to_check.size

    # start a new set of adjacent fields with the first field in fields_to_check
    current_swarm = Set.new
    field = fields_to_check.to_a.first
    fields_to_check.delete(field)
    current_swarm.add(field)

    # move all adjacent fields to the set
    loop do
      to_add = current_swarm
                 .map { |f| GameRuleLogic.neighbours(board, f)}
                 .flatten
                 .select { |f| fields_to_check.include? f }
      break if to_add.empty?
      fields_to_check -= to_add
      current_swarm += to_add
    end

    # keep trying to find bigger sets
    if current_swarm.size > current_biggest_swarm.size
      GameRuleLogic.greatest_swarm_from_fields(board, fields_to_check, current_swarm)
    else
      GameRuleLogic.greatest_swarm_from_fields(board, fields_to_check, current_biggest_swarm)
    end
  end

end
