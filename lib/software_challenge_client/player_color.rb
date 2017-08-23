# encoding: UTF-8
# player color constants
require 'typesafe_enum'
class PlayerColor < TypesafeEnum::Base

  new :NONE
  new :RED
  new :BLUE

  # Returns the opponents Color
  #
  # @param color [PlayerColor] The player's color, whose opponent needs to be found
  # @return [PlayerColor] the opponent's color
  def self.opponent_color(color)
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
