# encoding: UTF-8
require_relative 'player'

# Represents the winning condition received from the server when the game ended.
class Condition
  # @!attribute [r] winner
  # @return [Player] winning player
  attr_reader :winner

  # Initializes the winning Condition with a player
  # @param winer [Player] winning player
  def initialize(winner)
    @winner = winner
  end
end
