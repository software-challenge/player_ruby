# encoding: UTF-8

# A player, participating in a game
class Player
  # @!attribute [r] name
  # @return [PlayerColor] the player's name
  attr_reader :name

  # @!attribute [r] color
  # @return [PlayerColor] the player's color
  attr_reader :color

  # @!attribute [rw] points
  # @return [Integer] the player's points
  attr_accessor :points

  # @!attribute [rw] velocity
  # @return [Integer] the player's current velocity
  attr_accessor :velocity

  # @!attribute [rw] coal
  # @return [Integer] the player's current coal supply
  attr_accessor :coal

  # @!attribute [rw] direction
  # @return [Direction] the player's current direction
  attr_accessor :direction

  # @!attribute [rw] x
  # @return [Direction] the player's current x-position
  attr_accessor :x

  # @!attribute [rw] x
  # @return [Direction] the player's current y-position
  attr_accessor :y

  # Initializer
  # @param color [PlayerColor] the new player's color
  # @param name [String] the new player's name (for displaying)
  def initialize(color, name)
    @color = color
    @name = name
    @points = 0
    @velocity = 1
    @coal = 6
    @direction = Direction::RIGHT
  end

  def ==(other)
    color == other.color
  end
end
