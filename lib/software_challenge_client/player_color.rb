# encoding: UTF-8
#player color constants
module PlayerColor
  NONE = 1
  RED = 2
  BLUE = 4

  # Returns the opponents Color
  #
  # @param color [PlayerColor] The player's color, whose opponent needs to be found
  # @return [PlayerColor] the opponent's color
  def self.opponentColor(color)
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