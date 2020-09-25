# encoding: UTF-8
# frozen_string_literal: true

# Ein Feld des Spielfelds. Ein Spielfeld ist durch die Koordinaten eindeutig identifiziert.
class Field
  # @!attribute [rw] pieces
  # @return [Array<Piece>] Spielsteine auf dem Feld, beginnend beim untersten Stein
  attr_accessor :pieces
  # @!attribute [r] coordinates
  # @return [CubeCoordinates] die Cube-Coordinates des Feldes
  attr_reader :coordinates
  # @!attribute [r] obstructed
  # @return [Boolean] ob das Feld durch eine Brombeere blockiert ist
  attr_reader :obstructed

  # Konstruktor
  #
  # @param x [Integer] X-Koordinate
  # @param y [Integer] Y-Koordinate
  # @param pieces [Array<Piece>] Spielsteine auf dem Feld
  # @param obstructed [Boolean] Ob das Feld blockiert ist (Brombeere)
  def initialize(x, y, pieces = [], obstructed = false)
    @pieces = pieces
    @coordinates = CubeCoordinates.new(x, y)
    @obstructed = obstructed
  end

  # Vergleicht zwei Felder. Felder sind gleich, wenn sie gleiche Koordinaten und gleichen Typ haben.
  # @return [Boolean] true bei Gleichheit, false sonst.
  def ==(other)
    coordinates == other.coordinates &&
      obstructed == other.obstructed &&
      pieces == other.pieces
  end

  def x
    coordinates.x
  end

  def y
    coordinates.y
  end

  def z
    coordinates.z
  end

  # @return [Boolean] true, wenn eine Spielsteine auf dem Feld liegen und es nicht durch eine Brombeere blockiert ist
  def empty?
    pieces.empty? && !obstructed
  end

  # @return [Boolean] true, es nicht durch eine Brombeere blockiert ist
  def obstructed?
    obstructed
  end

  def add_piece(piece)
    pieces.push(piece)
  end

  # Entfernt den obersten Spielstein
  # @return [Piece] entfernten Spielstein oder nil
  def remove_piece
    pieces.pop
  end

  # @return [PlayerColor] Farbe des Spielers, der den obersten Spielstein kontrolliert. Ohne Spielsteine nil
  def color
    pieces.last&.color
  end

  def has_owner
    !color.nil?
  end

  # @return [String] Textuelle Darstellung des Feldes.
  def to_s
    s = "Feld #{coordinates}, "
    s += if obstructed?
           'blockiert'
         else
           "Steine: #{pieces.map(&:to_s).join(', ')}"
         end
  end
end
