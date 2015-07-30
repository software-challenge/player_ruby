# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require_relative 'player'

class Condition
  
  attr_reader :winner
  attr_reader :reason
  
  def initialize(winner, reason)
    @winner = winner
    @reason = reason
  end
  
end
