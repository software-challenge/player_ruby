# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

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
    self.color == another_player.color
  end
  
end
