# encoding: utf-8
# frozen_string_literal: true

# Konstanten zum aktuellen Spiel.
module Constants
  ROUND_LIMIT = 30 # Rundenbegrenzung. Nach Ende der angegebenen Runde endet auch das Spiel.
  GAME_IDENTIFIER = 'swc_2020_hive' # Der Identifikator des Spiels. Für die Kommunikation mit dem Spielserver.
  STARTING_PIECES = 'QSSSGGBBAAA' # Spielsteine, die jeder Spieler am Anfang des Spiels bekommt in textueller Repraesentation
  BOARD_SIZE = 11 # Durchmesser des Spielbretts in Feldern
  SHIFT = ((BOARD_SIZE - 1) / 2) # Wert, den man auf eine CubeCoordinate addieren muss, um einen positiven Index (fuer das Feld-Array) zu bekommen
end
