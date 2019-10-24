# encoding: utf-8
# player color constants
require 'typesafe_enum'

# Die Spielerfarben. RED oder BLUE
class PlayerColor < TypesafeEnum::Base
  new :RED, 'R'
  new :BLUE, 'B'

  # @param color [PlayerColor]
  # @return [PlayerColor] Farbe des Gegenspielers
  def self.opponent_color(color)
    case color
    when PlayerColor::RED
      PlayerColor::BLUE
    when PlayerColor::BLUE
      PlayerColor::RED
    end
  end

end
