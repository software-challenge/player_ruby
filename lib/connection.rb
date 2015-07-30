# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require_relative 'player_color'

class Connection
  attr_reader :x1
  attr_reader :x2
  attr_reader :y1
  attr_reader :y2
  attr_reader :owner
  
  def initialize(x1, y1, x2, y2, owner) 
    @x1 = x1
    @x2 = x2
    @y1 = y1
    @y2 = y2
    @owner = owner
  end
  
  def ==(another_connection)
    if(self.x1 == another_connection.x1 && self.y1 == another_connection.y1 && self.x2 == another_connection.x2 && self.y2 == another_connection.y2 ||
       self.x1 == another_connection.x2 && self.y1 == another_connection.y2 && self.x2 == another_connection.x1 && self.y2 == another_connection.y1) 
      owner == c.owner
    else
      false
    end
  end
end
