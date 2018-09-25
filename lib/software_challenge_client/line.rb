# coding: utf-8
# frozen_string_literal: true

require_relative './util/constants'
require_relative 'direction'
require_relative 'coordinates'
require_relative 'line_direction'

# Ein Iterator, der alle Koordinatenpaare auf einer Linie des Spielbrettes enthält.
class Line
  include Enumerable
  include Constants

  # Erzeugt einen neuen Iterator.
  #
  # @param start [Coordinates]
  # @param direction [LineDirection]
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
    when LineDirection::VERTICAL
      leftmost_x = @start.x
      leftmost_y = SIZE - 1
    when LineDirection::RISING_DIAGONAL
      # for rising diagonals, we have to decrease x and y
      shift = [@start.x, @start.y].min
      leftmost_x = @start.x - shift
      leftmost_y = @start.y - shift
    when LineDirection::FALLING_DIAGONAL
      # for falling diagonals, we have to decrease x and increase y
      shift = [@start.x, (SIZE - 1) - @start.y].min
      leftmost_x = @start.x - shift
      leftmost_y = @start.y + shift
    end
    @xi = leftmost_x
    @yi = leftmost_y

    @members = []
    while @xi >= 0 && @yi >= 0 && @xi < SIZE && @yi < SIZE
      @members << Coordinates.new(@xi, @yi)
      # horizontal lines and diagonals move right
      if [LineDirection::HORIZONTAL,
          LineDirection::RISING_DIAGONAL,
          LineDirection::FALLING_DIAGONAL].include? @direction
        @xi += 1
      end
      # vertical lines and falling diagonals move down
      if [LineDirection::VERTICAL,
          LineDirection::FALLING_DIAGONAL].include? @direction
        @yi -= 1
      elsif @direction == LineDirection::RISING_DIAGONAL
        # rising diagonals move up
        @yi += 1
      end
    end
  end

  def each(&block)
    @members.each(&block)
  end

  # Begrenzt den Iterator auf Koordinatenpaare von Feldern innerhalb der gegebenen beiden Koordinatenpaare (exklusive).
  # Kann als Filter verwendet werden.
  #
  # @example
  #   Line.new(
  #     Coordinates.new(2, 3), LineDirection::HORIZONTAL
  #   ).select do |c|
  #     Line.between(Coordinates.new(2, 3), Coordinates.new(5, 3), LineDirection::HORIZONTAL).call(c)
  #   end
  def self.between(start, bound, direction)
    lower_x = [start.x, bound.x].min
    lower_y = [start.y, bound.y].min
    higher_x = [start.x, bound.x].max
    higher_y = [start.y, bound.y].max
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

  # @param line_direction [LineDirection] Ausrichtung der Linie
  # @return [Array<Direction>] Die beiden Bewegungsrichtungen, die auf einer Linie mit der Ausrichtung möglich sind.
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

  # @param line_direction [Direction] Bewegungsrichtung
  # @return [Array<Direction>] Die Ausrichtung einer Linie, die auf der Bewegungsrichtung liegt.
  def self.line_direction_for_direction(direction)
    case direction
    when Direction::LEFT, Direction::RIGHT
      LineDirection::HORIZONTAL
    when Direction::UP, Direction::DOWN
      LineDirection::VERTICAL
    when Direction::UP_RIGHT, Direction::DOWN_LEFT
      LineDirection::RISING_DIAGONAL
    when Direction::UP_LEFT, Direction::DOWN_RIGHT
      LineDirection::FALLING_DIAGONAL
    end
  end
end
