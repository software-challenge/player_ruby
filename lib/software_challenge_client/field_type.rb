# encoding: utf-8

require 'typesafe_enum'
class FieldType < TypesafeEnum::Base
  new :EMPTY, '~'
  new :RED, 'R'
  new :BLUE, 'B'
  new :OBSTRUCTED, 'O'

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
