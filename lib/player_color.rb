# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

module PlayerColor
  NONE = 1
  RED = 2
  BLUE = 4
  
  def self.opponent(color)
    if color == PlayerColor::RED
      PlayerColor::BLUE
    end
    if color == PlayerColor::BLUE
      PlayerColor::RED
    end
    if color == PlayerColor::NONE
      PlayerColor::NONE
    end
  end
end
