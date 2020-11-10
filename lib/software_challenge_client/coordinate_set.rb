require_relative 'util/constants'

# Eine Menge aus Koordinaten
class CoordinateSet
  include Constants

  # @!attribute [r] coordinates
  # @return [Array<Coordinates>] Die enthaltenen Koordinaten.
  attr_reader :coordinates

  # Erstellt eine neue leere Koordinaten-Menge.
  def initialize(coordinates)
    @coordinates = coordinates
  end

  # Invertiert die X-Koordinate aller Koordinaten in dieser Menge
  def flip(should_flip = true)
    return self unless should_flip

    transform do |it|
      Coordinates.new(-it.x, it.y)
    end.align
  end

  # Enumeriert die enthaltenen Koordinaten
  def transform
    CoordinateSet.new(
      coordinates.map do |it|
        yield it
      end
    )
  end

  # Gibt die Größe des kleinsten Bereichs zurück, in dem alle enthaltenen Punkte liegen
  def area
    minX = coordinates.map(&:x).min
    minY = coordinates.map(&:y).min
    maxX = coordinates.map(&:x).max
    maxY = coordinates.map(&:y).max
    Coordinates.new(maxX - minX + 1, maxY - minY + 1)
  end

  # Bewege den Bereich der enthaltenen Koordinaten zum Ursprung
  def align
    minX = coordinates.map(&:x).min
    minY = coordinates.map(&:y).min
    transform do |it|
      Coordinates.new(it.x - minX, it.y - minY)
    end
  end

  # Wende eine Rotation auf den Stein an
  # @param rotation [Rotation] Die anzuwendene Rotation
  # @return [CoordinateSet] Die gedrehten Koordinaten
  def rotate(rotation)
    case rotation
    when Rotation::NONE
      self
    when Rotation::RIGHT
      turn_right.align
    when Rotation::MIRROR
      mirror.align
    when Rotation::LEFT
      turn_left.align
    end
  end

  # Drehe alle enthaltenen Koordinaten um 90° nach rechts
  def turn_right
    transform do |it|
      Coordinates.new(-it.y, it.x)
    end
  end

  # Drehe alle enthaltenen Koordinaten um 90° nach links
  def turn_left
    transform do |it|
      Coordinates.new(it.y, -it.x)
    end
  end

  # Spiegle alle enthaltenen Koordinaten um beide Achsen
  def mirror
    transform do |it|
      Coordinates.new(-it.x, -it.y)
    end
  end

  def ==(other)
    coordinates.sort == other.coordinates.sort
  end
end
