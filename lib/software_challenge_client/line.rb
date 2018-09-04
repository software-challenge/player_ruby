# coding: utf-8
# frozen_string_literal: true

require_relative './util/constants'
require_relative 'direction'
require_relative 'coordinate'
require_relative 'line_direction'

# an iterator with all field-coordinates on the line given by a field on it and
# a direction
class Line
  include Enumerable

  # start: Coordinates
  # direction: LineDirection
  def initialize(start, direction)
    @direction = direction
    @start = start
    # we will iterate from left to right, so find the leftmost field on the line
    # inside the field note that (0,0) is the lowest, leftmost point, x-axis
    # goes to the right, y-axis goes up
    case @direction
    when LineDirection::HORIZONTAL
      leftmost_x = 0
      leftmost_y = @start.y
      break
    when LineDirection::VERTICAL
      leftmost_x = @start.x
      leftmost_y = SIZE - 1
      break
    when LineDirection::RISING_DIAGONAL
      # for rising diagonals, we have to decrease x and y
      shift = Math.min(@start.x, @start.y)
      leftmost_x = @start.x - shift
      leftmost_y = @start.y - shift
      break
    when LineDirection::FALLING_DIAGONAL
      # for falling diagonals, we have to decrease x and increase y
      shift = Math.min(@start.x, (SIZE - 1) - @start.y)
      leftmost_x = @start.x - shift
      leftmost_y = @start.y + shift
      break
    end
    @xi = leftmost_x
    @yi = leftmost_y

    @members = []
    while xi >= 0 && yi >= 0 && xi < SIZE && yi < SIZE
      @members << Coordinate.new(xi, yi)
      # horizontal lines and diagonals move right
      if [LineDirection::HORIZONTAL,
          LineDirection::RISING_DIAGONAL,
          LineDirection.FALLING_DIAGONAL].include? direction
        @xi += 1
      end
      # vertical lines and falling diagonals move down
      if [LineDirection::VERTICAL,
          LineDirection::FALLING_DIAGONAL].include? direction
        @yi -= 1
      elsif direction == LineDirection::RISING_DIAGONAL
        # rising diagonals move up
        @yi += 1
      end
    end
  end

  def each(&block)
    @members.each(&block)
  end

  # limits a line to fields between the given start and end (excluding)
  # to be used as a filter
  # e.g. Line.new(2,3, HORIZONTAL).filter(between(2, 3, 5, 3, HORIZONTAL))
  def self.between(start, bound, direction)
    lower_x = Math.min(start.x, bound.x)
    lower_y = Math.min(start.y, bound.y)
    higher_x = Math.max(start.x, bound.x)
    higher_y = Math.max(start.y, bound.y)
    proc do |f|
      case direction
      when LineDirection::HORIZONTAL
        f.x > lower_x && f.x < higher_x
      when LineDirection::VERTICAL
        f.y > lower_y && f.y < higher_y
      when LineDirection::RISING_DIAGONAL, LineDirection::FALLING_DIAGONAL
        f.x > lower_x && f.x < higher_x && f.y > lower_y && f.y < higher_y
      else
        throw `unknown direction ${direction}`
      end
    end
  end

  def self.directions_for_line_direction(line_direction)
    case line_direction
    when LineDirection::HORIZONTAL
      [Direction::LEFT, Direction::RIGHT]
    when LineDirection::VERTICAL
      [Direction::UP, Direction::DOWN]
    when LineDirection::RISING_DIAGONAL
      [Direction::UP_RIGHT, Direction::DOWN_LEFT]
    when LineDirection::FALLING_DIAGONAL
      [Direction::UP_LEFT, Direction::DOWN_RIGHT]
    end
  end

  def line_direction_for_direction(direction)
    case direction
    when Direction::LEFT, Direction::RIGHT
      Direction::HORIZONTAL
    when Direction::UP, Direction::DOWN
      Direction::VERTICAL
    when Direction::UP_RIGHT, Direction::DOWN_LEFT
      Direction::RISING_DIAGONAL
    when Direction::UP_LEFT, Direction::DOWN_RIGHT
      Direction::FALLING_DIAGONAL
    end
  end
end
