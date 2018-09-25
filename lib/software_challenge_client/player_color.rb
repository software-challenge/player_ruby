# encoding: utf-8
# player color constants
require 'typesafe_enum'

# Die Spielerfarben. RED, BLUE oder NONE.
class PlayerColor < TypesafeEnum::Base
  new :NONE
  new :RED
  new :BLUE

  # @param color [PlayerColor]
  # @return [PlayerColor] Farbe des Gegenspielers
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

  # @param color [PlayerColor] Die Spielerfarbe, zu dem der Feldtyp ermittelt werden soll.
  # @return [FieldType] Der zur Spielerfarbe gehörende Feldtyp, also FieldType::RED für PlayerColor::RED und FieldType::BLUE für PlayerColor::BLUE. In allen anderen Fällen nil.
  # @see FieldType#player_color
  def self.field_type(color)
    case color
    when PlayerColor::RED
      FieldType::RED
    when PlayerColor::BLUE
      FieldType::BLUE
    end
  end
end
