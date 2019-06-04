# encoding: utf-8
# frozen_string_literal: true

require_relative './util/constants'
require_relative 'game_state'
require_relative 'field_type'
require_relative 'field'

# Ein Spielbrett bestehend aus 10x10 Feldern.
class Board
  # @!attribute [r] fields
  # @note Besser über die {#field} Methode auf Felder zugreifen.
  # @return [Array<Array<Field>>] Ein Feld wird an der Position entsprechend
  #   seiner Koordinaten im Array gespeichert.
  attr_reader :fields

  # Erstellt ein neues leeres Spielbrett.
  def initialize
    @fields = []
    (0..9).to_a.each do |y|
      @fields[y] = []
      (0..9).to_a.each do |x|
        @fields[y][x] = Field.new(x, y, FieldType::EMPTY)
      end
    end
  end

  def Debug(verbose = false)
    puts inspect
    puts 'verbose' if verbose
    
    nil
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
    @fields[field.y][field.x] = field
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
  # @param x [Integer] Die X-Koordinate des Feldes. 0..9, wobei Spalte 0 ganz links und Spalte 9 ganz rechts liegt.
  # @param y [Integer] Die Y-Koordinate des Feldes. 0..9, wobei Zeile 0 ganz unten und Zeile 9 ganz oben liegt.
  # @return [Field] Das Feld mit den gegebenen Koordinaten. Falls das Feld nicht
  #   exisitert (weil die Koordinaten ausserhalb von (0,0)..(9,9) liegen), wird nil zurückgegeben.
  def field(x, y)
    return nil if x.negative? || y.negative?
    fields.dig(y, x) # NOTE that #dig requires ruby 2.3+
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
    fields.reverse.map do |row|
      row.map { |f| f.type.value }.join(' ')
    end.join("\n")
  end

end
