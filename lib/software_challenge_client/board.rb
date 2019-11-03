# encoding: utf-8
# frozen_string_literal: true

require_relative './util/constants'
require_relative 'game_state'
require_relative 'field'

# Ein Spielbrett fuer Hive
class Board

  include Constants
  # @!attribute [r] fields
  # @note Besser über die {#field} Methode auf Felder zugreifen.
  # @return [Array<Array<Field>>] Ein Feld wird an der Position entsprechend
  #   seiner x und y CubeCoordinates im Array gespeichert.
  attr_reader :fields

  def self.field_amount(radius)
    return 1 if radius == 1
    (radius - 1) * 6 + Board.field_amount(radius - 1)
  end

  FIELD_AMOUNT = Board.field_amount((BOARD_SIZE + 1)/2)

  # Erstellt ein neues leeres Spielbrett.
  def initialize(fields = [])
    @fields = Board.empty_game_field
    fields.each{ |f| add_field(f) }
  end

  def self.empty_game_field
    fields = []
    (-SHIFT..SHIFT).to_a.each do |x|
      fields[x + SHIFT] ||= []
      ([-SHIFT, -x-SHIFT].max..[SHIFT, -x+SHIFT].min).to_a.each do |y|
        fields[x + SHIFT][y + SHIFT] = Field.new(x, y)
      end
    end
    fields
  end

  def clear
    @fields = []
  end

  def field_list
    @fields.flatten.select{ |e| !e.nil? }
  end

  # Vergleicht zwei Spielbretter. Gleichheit besteht, wenn zwei Spielbretter die
  # gleichen Felder enthalten.
  def ==(other)
    field_list == other.field_list
  end

  # Fügt ein Feld dem Spielbrett hinzu. Das übergebene Feld ersetzt das an den Koordinaten bestehende Feld.
  #
  # @param field [Field] Das einzufügende Feld.
  def add_field(field)
    @fields[field.x + SHIFT][field.y + SHIFT] = field
  end

  # Zugriff auf die Felder des Spielfeldes
  #
  # @param x [Integer] Die X-Koordinate des Feldes.
  # @param y [Integer] Die Y-Koordinate des Feldes.
  # @return [Field] Das Feld mit den gegebenen Koordinaten. Falls das Feld nicht exisitert, wird nil zurückgegeben.
  def field(x, y)
    return nil if (x < -SHIFT) || (y < -SHIFT)
    fields.dig(x + SHIFT, y + SHIFT) # NOTE that #dig requires ruby 2.3+
  end

  # Zugriff auf die Felder des Spielfeldes über ein Koordinaten-Paar.
  #
  # @param coordinates [CubeCoordinates] X- und Y-Koordinate als Paar, sonst wie
  # bei {Board#field}.
  #
  # @return [Field] Wie bei {Board#field}.
  #
  # @see #field
  def field_at(coordinates)
    field(coordinates.x, coordinates.y)
  end

  # Liefert alle Felder die dem Spieler mit der gegebenen Farbe gehoeren
  #
  # @param color [PlayerColor] Die Spielerfarbe
  # @return [Array<Field>] Alle Felder der angegebenen Farbe die das Spielbrett enthält.
  def fields_of_color(color)
    field_list.select{ |f| f.color == color }
  end

  def pieces
    field_list.map(&:pieces).flatten
  end

  def deployed_pieces(color)
    pieces.select { |p| p.color == color }
  end

  def clone
    Marshal.load(Marshal.dump(self))
  end

  # Gibt eine textuelle Repräsentation des Spielbrettes aus. Hier steht R für
  # einen roten Fisch, B für einen blauen, ~ für ein leeres Feld und O für ein
  # Kraken-Feld.
  def to_s
    field_list.sort_by(&:z).map{ |f| f.obstructed ? 'OO' : f.empty? ? '--' : f.pieces.last.to_s }.join
  end

end
