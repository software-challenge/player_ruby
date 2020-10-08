# encoding: UTF-8
# frozen_string_literal: true

# Ein Spieler
class Player
  # @!attribute [r] name
  # @return [String] der Name des Spielers, hat keine Auswirkungen auf das Spiel
  attr_reader :name

  # @!attribute [r] type
  # @return [PlayerType] erster (PlayerType::ONE) oder zweiter (PlayerType::TWO) Spieler
  attr_reader :type

  # Konstruktor
  # @param type [PlayerType] Erster oder zweiter
  # @param name [String] Name
  def initialize(type, name)
    @type = type
    @name = name
  end

  def ==(other)
    color == other.color
  end
end
