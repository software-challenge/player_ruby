# encoding: utf-8

require 'typesafe_enum'

# Die sechs möglichen Bewegungsrichtungen auf dem Spielbrett. Die Richtungen sind:
#
# - UP_RIGHT
# - RIGHT
# - DOWN_RIGHT
# - DOWN_LEFT
# - LEFT
# - UP_LEFT
#
# Zugriff erfolgt z.B. durch Direction::UP_RIGHT.
class Direction < TypesafeEnum::Base
  new :UP_RIGHT
  new :RIGHT
  new :DOWN_RIGHT
  new :DOWN_LEFT
  new :LEFT
  new :UP_LEFT

  # Verschiebt den durch das Koordinatenpaar angegebenen Punkt in die
  # entsprechende Richtung. Der resultierende Punkt kann ausserhalb des
  # Spielbrettes liegen. Dies kann mit {GameRuleLogic#inside_bounds?} geprüft
  # werden.
  # @param coordinates [CubeCoordinates] Das zu verschiebende Koordinatenpaar.
  # @param distance [Integer] Um wieviele Felder in die Richtung verschoben werden soll.
  def translate(start, distance = 1)
    shiftX = start.x
    shiftY = start.y
    shiftZ = start.z
    case self.key
    when :RIGHT
      shiftX = start.x + distance
      shiftY = start.y - distance
    when :LEFT
      shiftX = start.x - distance
      shiftY = start.y + distance
    when :UP_RIGHT
      shiftX = start.x + distance
      shiftZ = start.z - distance
    when :UP_LEFT
      shiftY = start.y + distance
      shiftZ = start.z - distance
    when :DOWN_RIGHT
      shiftY = start.y - distance
      shiftZ = start.z + distance
    when :DOWN_LEFT
      shiftX = start.x - distance
      shiftZ = start.z + distance
    end
    return CubeCoordinates.new(shiftX, shiftY, shiftZ)
  end
end
