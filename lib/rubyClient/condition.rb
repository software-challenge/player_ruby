require_relative 'player'

# winning condition
class Condition
  
  attr_reader :winner
  attr_reader :reason
  
  def initialize(winner, reason)
    @winner = winner
    @reason = reason
  end
  
end
