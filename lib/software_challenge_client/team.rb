# frozen_string_literal: true

require 'typesafe_enum'

require_relative 'color'

# Erster oder zweiter Spieler:
#
#   ONE
#   TWO
#
# Zugriff z.B. mit Team::ONE
class Team < TypesafeEnum::Base
  new :ONE, 'Red'
  new :TWO, 'Blue'

  # Gibt die zugehörige Farbe zurück
  def to_c
    if self == :ONE
      Color::RED
    else
      Color::BLUE
    end
  end
end
