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
    case color
    when PlayerColor::RED
      PlayerColor::BLUE
    when PlayerColor::BLUE
      PlayerColor::RED
    when PlayerColor::NONE
      PlayerColor::NONE
    end
  end

  def self.field_type(color)
    case color
    when PlayerColor::RED
      FieldType::RED
    when PlayerColor::BLUE
      FieldType::BLUE
    end
  end
end
