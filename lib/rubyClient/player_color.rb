#player color constants
module PlayerColor
  NONE = 1
  RED = 2
  BLUE = 4
  
  def self.opponent(color)
    if color == PlayerColor::RED
      return PlayerColor::BLUE
    end
    if color == PlayerColor::BLUE
      return PlayerColor::RED
    end
    if color == PlayerColor::NONE
      return PlayerColor::NONE
    end
  end
end
