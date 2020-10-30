# encoding: utf-8
# frozen_string_literal: true

# Ein Feld des Spielfelds. Ein Spielfeld ist durch die Koordinaten eindeutig
# identifiziert.
class Field
  # @!attribute [rw] color
  # @return [Color] Farbe des überdeckenden Spielsteins, falls vorhanden, sonst
  #                 nil
  attr_accessor :color
  # @!attribute [r] coordinates
  # @return [Coordinates] die X-Y-Koordinaten des Feldes
  attr_reader :coordinates

  # Konstruktor
  #
  # @param x [Integer] X-Koordinate
  # @param y [Integer] Y-Koordinate
  # @param color [Color] Farbe des Spielsteins, der das Feld überdeckt, nil falls kein Spielstein es überdeckt
  def initialize(x, y, color = nil)
    @color = color
    @coordinates = Coordinates.new(x, y)
  end

  # Vergleicht zwei Felder. Felder sind gleich, wenn sie gleiche Koordinaten und
  # gleichen Typ haben.
  # @return [Boolean] true bei Gleichheit, sonst false.
  def ==(other)
    coordinates == other.coordinates &&
      color == other.color
  end

  def x
    coordinates.x
  end

  def y
    coordinates.y
  end

  # @return [Boolean] true, wenn das Feld nich durch einen Spielstein überdeckt
  # ist, sonst false
  def empty?
    color.nil?
  end

  # @return [String] Textuelle Darstellung des Feldes.
  def to_s
    empty? ? '_' : color.value
  end
end
