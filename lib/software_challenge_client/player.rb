# encoding: UTF-8
# frozen_string_literal: true

# Ein Spieler
class Player
  # @!attribute [r] name
  # @return [String] der Name des Spielers, hat keine Auswirkungen auf das Spiel
  attr_reader :name

  # @!attribute [r] team
  # @return [Team] erster (Team::ONE) oder zweiter (Team::TWO) Spieler
  attr_reader :team

  # @!attribute [rw] fishes
  # @return [Integer] Anzahl Fische die dieser Spieler gesammelt hat
  attr_accessor :fishes

  # Konstruktor
  # @param type [Team] One oder Two
  # @param name [String] Name
  # @param amber [Integer] Menge der Fische die der Spieler hat
  def initialize(team, name, fishes = 0)
    @team = team
    @name = name
    @fishes = fishes
  end

  def ==(other)
    team == other.team
  end
end
