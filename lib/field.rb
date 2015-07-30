# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require_relative 'player_color'
require_relative 'field_type'

class Field
  attr_accessor :owner
  attr_accessor :type
  attr_reader :x
  attr_reader :y
  
  def initialize(type, x, y)
   self.owner = PlayerColor::NONE
   self.type = type
   @x = x
   @y = y
  end
  
  def ==(another_field)
    self.owner == another_field.owner && 
      self.type == another_field.type && 
      self.x == another_field.x && 
      self.y == another_field.y
  end
  
  def to_s
    "Field: x = #{self.x}, y = #{self.y}, owner = #{self.owner}, type = #{self.type}"
  end
end
