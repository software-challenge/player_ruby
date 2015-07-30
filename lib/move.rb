# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require_relative 'debug_hint'

class Move
  attr_reader :x
  attr_reader :y
  attr_reader :hints
  
  def initialize
    self.x = -1
    self.y = -1
  end
  
  def initialize(x, y)
    @x = x
    @y = y
    @hints = Array.new
  end
  
  def addHint(hint)
    @hints.push(hint);
  end
  
  def addHint(key, value)
    self.addHint(DebugHint.new(key, value))
  end
  
  def addHint(string)
    self.addHint(DebugHint.new(string))
  end
  
  def perform(state, player)
    if !self.nil? && !state.nil? 
      if self.x < Constants::SIZE && self.y < Constants::SIZE && 
          self.x >= 0 && self.y >= 0
        if state.getPossibleMoves.contains(self) 
          state.getBoard().put(self.x, self.y, player)
          player.setPoints(state.getPointsForPlayer(player.color))      
        else
          raise "Der Zug ist nicht möglich, denn der Platz ist bereits besetzt oder nicht besetzbar."
        end
      else
        raise "Startkoordinaten sind nicht innerhalb des Spielfeldes."
      end
    end
  end
  
  def ==(another_move)
    self.x = another_move.x && self.y == another_move.y
  end

def to_s
    "Move:(#{self.x},#{self.y})"
end

end
