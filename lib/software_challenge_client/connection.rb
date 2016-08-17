# encoding: UTF-8
require_relative 'player_color'

# A connection between two fields owned by a specific player
class Connection
  # @!attribute [r] x1
  # @return [Integer] x-coordinate starting point
  attr_reader :x1
  # @!attribute [r] x2
  # @return [Integer] y-coordinate starting point
  attr_reader :x2
  # @!attribute [r] y1
  # @return [Integer] x-coordinate ending point
  attr_reader :y1
  # @!attribute [r] y2
  # @return [Integer] y-coordinate ending point
  attr_reader :y2
  # @!attribute [r] ownerColor
  # @return [PlayerColor] connection's owner's color
  attr_reader :ownerColor

  # Initializer
  #
  # @param x1 [Integer] x-coordinate starting point
  # @param y1 [Integer] y-coordinate starting point
  # @param x2 [Integer] x-coordinate ending point
  # @param y2 [Integer] y-coordinate ending point
  # @param owner [PlayerColor] connection's owner's color
  def initialize(x1, y1, x2, y2, ownerColor)
    @x1 = x1
    @x2 = x2
    @y1 = y1
    @y2 = y2
    @ownerColor = ownerColor
  end

  def ==(another_connection)
    if (self.x1 == another_connection.x1 &&
        self.y1 == another_connection.y1 &&
        self.x2 == another_connection.x2 &&
        self.y2 == another_connection.y2 ||
        self.x1 == another_connection.x2 &&
        self.y1 == another_connection.y2 &&
        self.x2 == another_connection.x1 &&
        self.y2 == another_connection.y1)
      return ownerColor == another_connection.ownerColor
    else
      return false
    end
  end

  def to_s
    return "#{self.ownerColor} : (#{self.x1}, #{self.y1}) - (#{self.x2}, #{self.y2})"
  end
end
