# encoding: utf-8
# frozen_string_literal: true

require_relative './util/constants'
require_relative 'game_state'
require_relative 'field'

# Ein Spielbrett fuer Ostseeschach 
class Board
  include Constants

  # @!attribute [r] fields
  # @note Besser über die {#field} Methode auf Felder zugreifen.
  # @return [Array<Array<Field>>] Ein Feld wird an der Position entsprechend
  #   seiner x und y Coordinates im Array gespeichert.
  attr_reader :fields

  # Erstellt ein neues leeres Spielbrett.
  def initialize(fields = [])
    @fields = Board.empty_game_field
    fields.each { |f| add_field(f) }
  end

  def update_cover
    [Color::RED,Color::BLUE].each do |color|
      fields_of_color(color).each do |field|
        field.piece.target_coords.each do |coord|
          field(coord).add_covered(color)
        end
      end
    end
  end

  # @return [Array] leere Felder entsprechend des Spielbrettes angeordnet
  def self.empty_game_field
    (0...BOARD_SIZE).to_a.map do |x|
      (0...BOARD_SIZE).to_a.map do |y|
        Field.new(x, y)
      end
    end
  end

  # Entfernt alle Felder des Spielfeldes
  def clear
    @fields = []
  end

  # @return [Array] Liste aller Felder
  def field_list
    @fields.flatten.reject(&:nil?)
  end

  # Vergleicht zwei Spielbretter. Gleichheit besteht, wenn zwei Spielbretter die
  # gleichen Felder enthalten.
  def ==(other)
    field_list == other.field_list
  end

  # Fügt ein Feld dem Spielbrett hinzu. Das übergebene Feld ersetzt das an den
  # Koordinaten bestehende Feld.
  #
  # @param field [Field] Das einzufügende Feld.
  def add_field(field)
    @fields[field.x][field.y] = field
  end

  # Zugriff auf die Felder des Spielfeldes
  #
  # @param x [Integer] Die X-Koordinate des Feldes.
  # @param y [Integer] Die Y-Koordinate des Feldes.
  # @return [Field] Das Feld mit den gegebenen Koordinaten. Falls das Feld nicht
  #                 exisitert, wird nil zurückgegeben.
  def field(x, y)
    fields.dig(x, y) # NOTE that #dig requires ruby 2.3+
  end

  # Zugriff auf die Felder des Spielfeldes über ein Koordinaten-Paar.
  #
  # @param coordinates [Coordinates] X- und Y-Koordinate als Paar, sonst wie
  # bei {Board#field}.
  #
  # @return [Field] Wie bei {Board#field}.
  #
  # @see #field
  def field_at(coordinates)
    field(coordinates.x, coordinates.y)
  end

  def fields_of_color(color)
    fields = []

    (0...BOARD_SIZE).to_a.map do |x|
      (0...BOARD_SIZE).to_a.map do |y|
        f = field(x,y)
        if (f.color == color)
          fields << f
        end
      end
    end

    fields
  end

  # @param it [Coordinates] Die zu untersuchenden Koordinaten
  # @return [Boolean] Ob die gegebenen Koordinaten auf dem Board liegen oder nicht
  def in_bounds?(it)
    it.x >= 0 && it.y >= 0 && it.x < BOARD_SIZE && it.y < BOARD_SIZE
  end

  # @return eine unabhaengige Kopie des Spielbretts
  def clone
    Marshal.load(Marshal.dump(self))
  end

  # @param coords [Coordinates] Die Koordinaten des Felds
  # @return Das Feld an den gegebenen Koordinaten
  def [](coords)
    field_at(coords)
  end

  # Gibt eine textuelle Repräsentation des Spielbrettes aus.
  def to_s
    "\n" +
      (0...BOARD_SIZE).to_a.map do |y|
        (0...BOARD_SIZE).to_a.map do |x|
          @fields[x][y].to_s
        end.join(' ')
      end.join("\n")
  end

  # @param position [Coordinates] Die zu überprüfenden Koordinaten
  # @return Ob die gegebenen Koordinaten auf dem board liegen
  def self.contains(position)
    position.x >= 0 && position.x < BOARD_SIZE &&
      position.y >= 0 && position.y < BOARD_SIZE
  end
end
