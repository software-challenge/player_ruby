require_relative 'player_color'

class Player
  attr_reader :color
  attr_accessor :points
  
  def initialize
    self.points = 0
  end
  
  def initialize(color)
    @color = color
  end
  
  def ==(another_player)
    return self.color == another_player.color
  end
  
end
