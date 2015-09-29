# encoding: UTF-8
require_relative 'player'

# @author Ralf-Tobias Diekert
# winning condition
class Condition
  # @!attribute [r] winner
  # @return [Player] winning player
  attr_reader :winner
  # @!attribute [r] reason
  # @return [String] winning reason
  attr_reader :reason
  
  # Initializes the winning Condition with a player and a reason
  # @param winer [Player] winning player
  # @param reason [String] winning reason
  def initialize(winner, reason)
    @winner = winner
    @reason = reason
  end
  
end