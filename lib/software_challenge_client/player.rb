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

  # Initializer
  # @param the new player's color
  def initialize(color, name)
    @color = color
    @name = name
    self.points = 0
  end

  def ==(another_player)
    return self.color == another_player.color
  end

end
