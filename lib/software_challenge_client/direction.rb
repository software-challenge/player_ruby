# frozen_string_literal: true

require 'typesafe_enum'

# Eine der sechs Richtungen im hexagonalen Koordinatensystem:
#
#   TOPLEFT,
#   TOPRIGHT,
#   RIGHT,
#   BOTTOMRIGHT,
#   BOTTOMLEFT,
#   LEFT
#
# Zugriff z.B. mit Direction::BOTTOMLEFT
class Direction < TypesafeEnum::Base
  new :TOPLEFT,
  new :TOPRIGHT,
  new :RIGHT,
  new :BOTTOMRIGHT,
  new :BOTTOMLEFT,
  new :LEFT,

  # @return [Coordinates] Gibt den zugehörigen Vector als Koordinate zurück
  def to_vec
    if self.key == :TOPLEFT
      Coordinates.new(-1, -1)
    if self.key == :TOPRIGHT
      Coordinates.new(1, -1)
    if self.key == :RIGHT
      Coordinates.new(2, 0)
    if self.key == :BOTTOMRIGHT
      Coordinates.new(1, 1)
    if self.key == :BOTTOMLEFT
      Coordinates.new(-1, 1)
    if self.key == :LEFT
      Coordinates.new(-2, 0)
    else
      Color::BLUE
    end
  end
end
