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

  def self.move_target(move, board)
    speed = GameRuleLogic.count_fish(
      board, move.from_field,
      Line.line_direction_for_direction(move.direction)
    )
    c = move.target_field(speed)
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

  def self.valid_move(move, board)
    if board.field(move.x, move.y).type == FieldType::RED
      moving_player_color = PlayerColor::RED
    elsif board.field(move.x, move.y).type == FieldType::BLUE
      moving_player_color = PlayerColor::BLUE
    else
      # moving from a field which is not occupied by a fish is invalid
      return false
    end

    target = GameRuleLogic.move_target(move, board)

    GameRuleLogic.inside_bounds?(target) &&
      GameRuleLogic.valid_move_target(target, moving_player_color, board) &&
      GameRuleLogic.no_obstacle?(
        move.from_field,
        Line.line_direction_for_direction(move.direction),
        target, moving_player_color, board
      )
  end

  def self.possible_moves(board, field)
    ALL_DIRECTIONS.map do |direction|
      Line.directions_for_line_direction(direction)
          .map { |d| Move.new(field, d) } # create two moves for every line direction
          .filter { |m| GameRuleLogic.valid_move(m, board) } # remove invalid moves
    end.flatten
  end
end
