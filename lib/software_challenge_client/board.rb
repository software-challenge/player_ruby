# encoding: utf-8
# frozen_string_literal: true

require_relative './util/constants'
require_relative 'game_state'
require_relative 'field'

# Ein Spielbrett bestehend aus 10x10 Feldern.
class Board
  # @!attribute [r] fields
  # @note Besser über die {#field} Methode auf Felder zugreifen.
  # @return [Array<Array<Field>>] Ein Feld wird an der Position entsprechend
  #   seiner Koordinaten im Array gespeichert.
  attr_reader :fields

  BOARD_SIZE = 11
  SHIFT = ((BOARD_SIZE - 1) / 2)

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

  def field_list
    @fields.flatten.select{ |e| !e.nil? }
  end

  # Vergleicht zwei Spielbretter. Gleichheit besteht, wenn zwei Spielbretter die
  # gleichen Felder enthalten.
  def ==(other)
    fields.each_with_index do |row, y|
      row.each_with_index do |field, x|
        return false if field != other.field(x, y)
      end
    end
    true
  end

  # Fügt ein Feld dem Spielbrett hinzu. Das übergebene Feld ersetzt das an den Koordinaten bestehende Feld.
  #
  # @param field [Field] Das einzufügende Feld.
  def add_field(field)
    @fields[field.y + SHIFT][field.x + SHIFT] = field
  end

  # Ändert den Typ eines bestimmten Feldes des Spielbrettes.
  #
  # @param x [Integer] Die X-Koordinate des zu ändernden Feldes. 0..9, wobei Spalte 0 ganz links und Spalte 9 ganz rechts liegt.
  # @param y [Integer] Die Y-Koordinate des zu ändernden Feldes. 0..9, wobei Zeile 0 ganz unten und Zeile 9 ganz oben liegt.
  # @param type [FieldType] Der neue Typ des Feldes.
  def change_field(x, y, type)
    @fields[y][x].type = type
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
  # @param coordinates [Coordinates] X- und Y-Koordinate als Paar, sonst wie bei {Board#field}.
  # @return [Field] Wie bei {Board#field}.
  #
  # @see #field
  def field_at(coordinates)
    field(coordinates.x, coordinates.y)
  end

  # Liefert alle Felder eines angegebenen Typs des Spielbrettes.
  #
  # @param field_type [FieldType] Der Typ, dessen Felder zurückgegeben werden sollen.
  # @return [Array<Field>] Alle Felder des angegebenen Typs die das Spielbrett enthält.
  def fields_of_type(field_type)
    fields.flatten.select{ |f| f.type == field_type }
  end

  # Gibt eine textuelle Repräsentation des Spielbrettes aus. Hier steht R für
  # einen roten Fisch, B für einen blauen, ~ für ein leeres Feld und O für ein
  # Kraken-Feld.
  def to_s
    field_list.map{ |f| f.obstructed ? 'OO' : f.empty? ? '--' : f.pieces.first.to_s }.join
  end

end
