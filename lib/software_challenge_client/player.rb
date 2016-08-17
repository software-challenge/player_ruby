# encoding: UTF-8
require_relative 'player_color'

# A player, participating at a game
class Player
  # @!attribute [r] color
  # @return [PlayerColor] the player's color
  attr_reader :color
  # @!attribute [rw] points
  # @return [Integer] the player's points
  attr_accessor :points

  # Initializer
  # @param the new player's color
  def initialize(color)
    @color = color
    self.points = 0
  end

  def ==(another_player)
    return self.color == another_player.color
  end

end