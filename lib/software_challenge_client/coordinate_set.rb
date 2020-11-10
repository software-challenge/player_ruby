require_relative 'util/constants'

class CoordinateSet
  include Constants

  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end

  def flip(should_flip = true)
    return self unless should_flip

    transform do |it|
      Coordinates.new(-it.x, it.y)
    end.align
  end

  def transform
    CoordinateSet.new(
      coordinates.map do |it|
        yield it
      end
    )
  end

  def area
    minX = coordinates.map(&:x).min
    minY = coordinates.map(&:y).min
    maxX = coordinates.map(&:x).max
    maxY = coordinates.map(&:y).max
    Coordinates.new(maxX - minX + 1, maxY - minY + 1)
  end

  def align
    minX = coordinates.map(&:x).min
    minY = coordinates.map(&:y).min
    transform do |it|
      Coordinates.new(it.x - minX, it.y - minY)
    end
  end

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

  def turn_right
    transform do |it|
      Coordinates.new(-it.y, it.x)
    end
  end

  def turn_left
    transform do |it|
      Coordinates.new(it.y, -it.x)
    end
  end

  def mirror
    transform do |it|
      Coordinates.new(-it.x, -it.y)
    end
  end

  def ==(other)
    coordinates.sort == other.coordinates.sort
  end
end
