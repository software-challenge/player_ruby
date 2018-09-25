# encoding: utf-8

require 'typesafe_enum'

# Die acht möglichen Bewegungsrichtungen auf dem Spielbrett. Die Richtungen sind:
#
# - UP
# - UP_RIGHT
# - RIGHT
# - DOWN_RIGHT
# - DOWN
# - DOWN_LEFT
# - LEFT
# - UP_LEFT
#
# Zugriff erfolgt z.B. durch Direction::UP_RIGHT.
class Direction < TypesafeEnum::Base
  new :UP
  new :UP_RIGHT
  new :RIGHT
  new :DOWN_RIGHT
  new :DOWN
  new :DOWN_LEFT
  new :LEFT
  new :UP_LEFT

  # Verschiebt den durch das Koordinatenpaar angegebenen Punkt in die
  # entsprechende Richtung. Der resultierende Punkt kann ausserhalb des
  # Spielbrettes liegen. Dies kann mit {GameRuleLogic#inside_bounds?} geprüft
  # werden.
  # @param coordinates [Coordinates] Das zu verschiebende Koordinatenpaar.
  # @param distance [Integer] Um wieviele Felder in die Richtung verschoben werden soll.
  def translate(coordinates, distance = 1)
    case key
    when :UP
      Coordinates.new(coordinates.x, coordinates.y + distance)
    when :UP_RIGHT
      Coordinates.new(coordinates.x + distance, coordinates.y + distance)
    when :RIGHT
      Coordinates.new(coordinates.x + distance, coordinates.y)
    when :DOWN_RIGHT
      Coordinates.new(coordinates.x + distance, coordinates.y - distance)
    when :DOWN
      Coordinates.new(coordinates.x, coordinates.y - distance)
    when :DOWN_LEFT
      Coordinates.new(coordinates.x - distance, coordinates.y - distance)
    when :LEFT
      Coordinates.new(coordinates.x - distance, coordinates.y)
    when :UP_LEFT
      Coordinates.new(coordinates.x - distance, coordinates.y + distance)
    end
  end
end
