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
  # @return [Array<Array<Field>>] Ein Feld wird an der Position entsprechend seiner
  #   Koordinaten im Array gespeichert.
  attr_reader :fields

  # Initializes the board
  def initialize
    @fields = []
    (0..9).to_a.each do |x|
      @fields[x] = []
      (0..9).to_a.each do |y|
      end
    end
  end

  def to_s
    fields.map { |f| f.type.value }.join(' ')
  end

  def ==(other)
    fields.each_with_index do |field, index|
      return false if field != other.field(index)
    end
    true
  end

  # Zugriff auf die Felder des Spielfeldes
  #
  # @param x [Integer] Die X-Koordinate des Feldes. 0..9, wobei Spalte 0 ganz links und Spalte 9 ganz rechts liegt.
  # @param y [Integer] Die Y-Koordinate des Feldes. 0..9, wobei Zeile 0 ganz unten und Zeile 9 ganz oben liegt.
  # @return [Field] Das Feld mit den gegebenen Koordinaten. Falls das Feld nicht
  #   exisitert (weil die Koordinaten ausserhalb von (0,0)..(9,9) liegen), wird nil zurückgegeben.
  def field(x, y)
    return nil if x.negative? || y.negative?
    fields.dig(x, y) # NOTE that #dig requires ruby 2.3+
  end
end
