# encoding: utf-8

require 'typesafe_enum'
# Der Typ eines Feldes des Spielbrettes. Es gibt folgende Typen:
# - EMPTY
# - RED
# - BLUE
# - OBSTRUCTED
#
# Zugriff z.B. mit FieldType::RED
class FieldType < TypesafeEnum::Base
  new :EMPTY, '~'
  new :RED, 'R'
  new :BLUE, 'B'
  new :OBSTRUCTED, 'O'

  # @param field_type [FieldType] Der Feldtyp, zu dem die Spielerfarbe ermittelt werden soll.
  # @return [PlayerColor] Die zum Feldtyp gehörende Spielerfarbe, also PlayerColor::RED für FieldType::RED und PlayerColor::BLUE für FieldType::BLUE. In allen anderen Fällen PlayerColor::NONE.
  # @see PlayerColor#field_type
  def self.player_color(field_type)
    case field_type
    when FieldType::RED
      PlayerColor::RED
    when FieldType::BLUE
      PlayerColor::BLUE
    else
      PlayerColor::NONE
    end
  end
end
