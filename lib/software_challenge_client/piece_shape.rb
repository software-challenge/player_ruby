# frozen_string_literal: true

require 'typesafe_enum'

require_relative 'coordinates'
require_relative 'coordinate_set'

# Die Form eines Spielsteins. Es gibt folgende Formen:
#
#   MONO
#   DOMINO
#   TRIO_L
#   TRIO_I
#   TETRO_O
#   TETRO_T
#   TETRO_I
#   TETRO_L
#   TETRO_Z
#   PENTO_L
#   PENTO_T
#   PENTO_V
#   PENTO_S
#   PENTO_Z
#   PENTO_I
#   PENTO_P
#   PENTO_W
#   PENTO_U
#   PENTO_R
#   PENTO_X
#   PENTO_Y
#
# Zugriff z.B. mit PieceShape::PENTO_S
class PieceShape < TypesafeEnum::Base
  def self.c(x, y)
    Coordinates.new(x, y)
  end
  new :MONO, [c(0, 0)]
  new :DOMINO, [c(0, 0), c(1, 0)]
  new :TRIO_L, [c(0, 0), c(0, 1), c(1, 1)]
  new :TRIO_I, [c(0, 0), c(0, 1), c(0, 2)]
  new :TETRO_O, [c(0, 0), c(1, 0), c(0, 1), c(1, 1)]
  new :TETRO_T, [c(0, 0), c(1, 0), c(2, 0), c(1, 1)]
  new :TETRO_I, [c(0, 0), c(0, 1), c(0, 2), c(0, 3)]
  new :TETRO_L, [c(0, 0), c(0, 1), c(0, 2), c(1, 2)]
  new :TETRO_Z, [c(0, 0), c(1, 0), c(1, 1), c(2, 1)]
  new :PENTO_L, [c(0, 0), c(0, 1), c(0, 2), c(0, 3), c(1, 3)]
  new :PENTO_T, [c(0, 0), c(1, 0), c(2, 0), c(1, 1), c(1, 2)]
  new :PENTO_V, [c(0, 0), c(0, 1), c(0, 2), c(1, 2), c(2, 2)]
  new :PENTO_S, [c(1, 0), c(2, 0), c(3, 0), c(0, 1), c(1, 1)]
  new :PENTO_Z, [c(0, 0), c(1, 0), c(1, 1), c(1, 2), c(2, 2)]
  new :PENTO_I, [c(0, 0), c(0, 1), c(0, 2), c(0, 3), c(0, 4)]
  new :PENTO_P, [c(0, 0), c(1, 0), c(0, 1), c(1, 1), c(0, 2)]
  new :PENTO_W, [c(0, 0), c(0, 1), c(1, 1), c(1, 2), c(2, 2)]
  new :PENTO_U, [c(0, 0), c(0, 1), c(1, 1), c(2, 1), c(2, 0)]
  new :PENTO_R, [c(0, 1), c(1, 1), c(1, 2), c(2, 1), c(2, 0)]
  new :PENTO_X, [c(1, 0), c(0, 1), c(1, 1), c(2, 1), c(1, 2)]
  new :PENTO_Y, [c(0, 1), c(1, 0), c(1, 1), c(1, 2), c(1, 3)]

  @transformations = nil
  Transform = Struct.new(:r, :f, :coords)

  # Anzahl Felder, die der Stein belegt
  def size
    value.size
  end

  # Die Felder, die der Stein belegt
  def coordinates
    CoordinateSet.new(value)
  end

  # Eine Koordinate, die das kleinstmögliche Rechteck beschreibt, welches alle Felder umfasst.
  def dimension
    coordinates.area
  end

  # Erzeugt eine nach Rotation und Flip transformierte Form
  def transform(rotation, flip)
    coordinates.rotate(rotation).flip(flip)
  end

  def unique_transforms()
    if @transformations == nil then
      existing_transforms = []

      Rotation.each do |r|
        [true, false].each do |f|
          new_transform = Transform.new(r, f, transform(r, f))

          if existing_transforms.all? { |t| t.coords != new_transform.coords } then
            existing_transforms << new_transform
          end
        end
      end

      @transformations = existing_transforms
      @transformations
    else
      @transformations
    end
  end

  # Gibt den Form Namen zurück
  def to_s
    self.key.to_s
  end
end
