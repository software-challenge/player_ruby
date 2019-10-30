# encoding: UTF-8

# Ein Feld des Spielfelds. Ein Spielfeld ist durch die Koordinaten eindeutig identifiziert.
# Das type Attribut gibt an, um welchen Feldtyp es sich handelt
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
  # @param type [FieldType] Feldtyp
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

  def empty?
    pieces.empty? && !obstructed
  end

  def add_piece(piece)
    pieces.push(piece)
  end

  def remove_piece
    pieces.pop
  end

  def color
    pieces.last&.color
  end

  # @return [String] Textuelle Darstellung des Feldes.
  def to_s
    s = "Feld #{coordinates}, "
    if obstructed?
      s += 'blockiert'
    else
      s += "Steine: #{pieces.inpect}"
    end
  end
end
