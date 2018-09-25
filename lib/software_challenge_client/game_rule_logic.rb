# coding: utf-8
# frozen_string_literal: true

require_relative 'field_type'
require_relative 'line'
require_relative './util/constants'

# Methoden, welche die Spielregeln von Piranhas abbilden.
#
# Es gibt hier viele Helfermethoden, die von den beiden Hauptmethoden {GameRuleLogic#valid_move?} und {GameRuleLogic.possible_moves} benutzt werden.
class GameRuleLogic

  include Constants

  # Fügt einem leeren Spielfeld zwei Krakenfelder hinzu. Die beiden Felder
  # liegen nicht auf derselben Horizontalen, Vertikalen oder Diagonalen und sind
  # mindestens zwei Felder von den Rändern des Spielbrettes entfernt.
  #
  # Diese Methode ist dazu gedacht, ein initiales Spielbrett regelkonform zu generieren.
  #
  # @param board [Board] Das zu modifizierende Spielbrett. Es wird nicht
  #   geprüft, ob sich auf dem Spielbrett bereits Krakenfelder befinden.
  # @return [Board] Das modifizierte Spielbrett.
  def self.add_blocked_fields(board)
    number_of_blocked_fields = 2
    lower_bound = 2 # first row or column, in which blocked fields are allowed
    upper_bound = 7 # last row or column, in which blocked fields are allowed

    # create a list of coordinates for fields which may be blocked
    blockable_field_coordinates = (lower_bound..upper_bound).to_a.map do |x|
      (lower_bound..upper_bound).to_a.map do |y|
        Coordinate.new(x, y)
      end
    end.flatten

    # set fields with randomly selected coordinates to blocked coordinates may
    # not lay on same horizontal, vertical or diagonal lines with other selected
    # coordinates
    number_of_blocked_fields.times do
      selected_coords = blockable_field_coordinates.sample
      board.change_field(selectedCoords, FieldType::OBSTRUCTED)
      # remove field coordinates and fields on horizontal, vertical and diagonal
      # lines:
      coordinates_to_remove = ALL_DIRECTIONS.map do |direction|
        Line.new(selected_coords, direction).to_a
      end.flatten
      blockable_field_coordinates = blockable_field_coordinates.filter do |c|
        coordinates_to_remove.none? do |to_remove|
          c.x == to_remove.x && c.y == to_remove.y
        end
      end
    end
    board
  end

  # Ermittlung der Anzahl der Fische auf einer Line des Spielbrettes.
  #
  # @param board [Board] Das zu betrachtende Spielbrett.
  # @param start [Coordinates] Ein Feld auf der Linie.
  # @param direction [LineDirection] Die Ausrichtung der Linie (vertikal, horizontal oder diagonal).
  # @return [Integer] Anzahl der Fische auf der Linie.
  def self.count_fish(board, start, direction)
    # filter function for fish field type
    fish = proc { |f| f.type == FieldType::RED || f.type == FieldType::BLUE }
    Line.new(start, direction).to_a.map do |p|
      board.field(p.x, p.y)
    end.select(&fish).size
  end

  # @return [Coordinates] Die Zielkoordinaten eines Spielzuges auf einem Spielbrett.
  def self.target_coordinates(move, board)
    speed = GameRuleLogic.count_fish(
      board, move.from_field,
      Line.line_direction_for_direction(move.direction)
    )
    move.target_field(speed)
  end

  # @return [Field] Das Zielfeld eines Spielzuges auf einem Spielbrett.
  def self.move_target(move, board)
    c = GameRuleLogic.target_coordinates(move, board)
    board.field(c.x, c.y)
  end

  # Prüft, ob sich die gegebenen Koordinaten innerhalb des Spielbrettes befinden.
  # @return [Boolean]
  def self.inside_bounds?(coordinates)
    coordinates.x >= 0 &&
      coordinates.x < SIZE &&
      coordinates.y >= 0 &&
      coordinates.y < SIZE
  end

  # Ermittelt, ob der gegebene Feldtyp für den Spieler mit der angegebenen Farbe ein nicht überspringbares Hindernis darstellt.
  # @param field_type [FieldType]
  # @param moving_player_color [PlayerColor]
  # @return [Boolean] true, falls es ein Hindernis ist, false sonst.
  def self.obstacle?(field_type, moving_player_color)
    field_type == PlayerColor.field_type(
      PlayerColor.opponent_color(moving_player_color)
    )
  end

  # Ermittelt, ob sich zwischen den angegebenen Feldern kein Hindernis befindet.
  # @param from_field [Coordinates] Startfeld
  # @param to_field [Coordinates] Zielfeld
  # @param direction [LineDirection] Ausrichtung der Linie zwischen Start- und Zielfeld.
  # @param color [PlayerColor] Farbe des ziehenden Spielers.
  # @param board [Board] Das aktuelle Spielbrett.
  # @return [Boolean] true, falls der Spieler mit der angegebenen Farbe zwischen den beiden Punkten ein Hindernis vorfindet, false sonst.
  def self.obstacle_between?(from_field, direction, to_field, color, board)
    Line.new(from_field, direction)
        .to_a
        .select { |c| Line.between(from_field, to_field, direction).call(c) }
        .any? { |f| GameRuleLogic.obstacle?(board.field(f.x, f.y).type, color) }
  end

  # Ermittelt, ob der Spieler mit der angegebenen Farbe einen Fisch auf dem Feld mit den angegebenen Koordinaten besitzt.
  # @param target [Coordinates] Koordinaten des Feldes.
  # @param moving_player_color [PlayerColor] Farbe des Spielers, der einen Zug machen will.
  # @param board [Board] Aktuelles Spielbrett.
  # @return [Boolean] true falls sich auf dem Feld ein Fisch mit der richtigen Farbe befindet (Rot für roten Spieler, Blau für blauen Spieler), false sonst.
  def self.valid_move_target(target, moving_player_color, board)
    target_field_type = board.field(target.x, target.y).type
    target_field_type == FieldType::EMPTY ||
      target_field_type == PlayerColor.field_type(
        PlayerColor.opponent_color(moving_player_color)
      )
  end

  # Ermittelt, ob der gegebene Zug regelkonform ausgeführt werden kann.
  # @param move [Move] Der zu prüfende Zug
  # @param board [Board] Spielbrett, auf dem der Zug ausgeführt werden soll.
  # @param current_player_color [PlayerColor] Farbe des Spielers, der den Zug ausführen soll.
  # @return [Boolean] true falls der Zug gültig ist, false sonst.
  def self.valid_move?(move, board, current_player_color)
    from_field_type = board.field(move.x, move.y).type
    return false unless
      [FieldType::BLUE, FieldType::RED].include? from_field_type
    return false unless
      current_player_color == FieldType.player_color(from_field_type)

    return false unless
      GameRuleLogic.inside_bounds?(
        GameRuleLogic.target_coordinates(move, board)
      )

    target = GameRuleLogic.move_target(move, board)

    GameRuleLogic.valid_move_target(target, current_player_color, board) &&
      !GameRuleLogic.obstacle_between?(
        move.from_field,
        Line.line_direction_for_direction(move.direction),
        target, current_player_color, board
      )
  end

  # Ermittelt alle möglichen Züge von einem bestimmten Feld aus.
  # @param board [Board] Aktuelles Spielbrett
  # @param field [Field] Das Feld, von dem die Züge ausgehen sollen.
  # @param current_player_color [PlayerColor] Farbe des Spielers, der den Zug macht.
  # @return [Array<Move>] Liste von möglichen Zügen.
  def self.possible_moves(board, field, current_player_color)
    Direction.map { |direction| Move.new(field.x, field.y, direction) }
             .select do |m|
               GameRuleLogic.valid_move?(m, board, current_player_color)
             end
  end

  # Ermittelt die Schwarmgröße eines Spielers auf dem Spielbrett.
  # @param board [Board] Das zu betrachtende Spielbrett.
  # @param player_color [PlayerColor] Farbe des Spielers, für den die Schwarmgröße ermittelt werden soll.
  # @return [Integer] Anzahl der Fische im größten Schwarm des Spielers.
  def self.swarm_size(board, player_color)
    GameRuleLogic.greatest_swarm_from_fields(
      board,
      board.fields_of_type(
        PlayerColor.field_type(player_color)
      ).to_set,
      Set.new
    ).size
  end

  # @return [Array<Field>] Alle direkten Nachbarfelder des gegebenen Feldes. Für Felder im Inneren des Spielbrettes gibt es acht Nachbarfelder. Für Randfelder vier oder drei Nachbarfelder.
  def self.neighbours(board, field)
    Direction
      .map { |d| d.translate(field.coordinates) }
      .select { |c| GameRuleLogic.inside_bounds?(c) }
      .map { |c| board.field_at(c) }
  end

  # Hilfsfunktion für {GameRuleLogic.swarm_size}.
  # Ermittelt die größte zusammenhängende Menge von Feldern aus einer gegebenen Menge von Feldern.
  # @param board [Board] Das zu betrachtende Spielbrett.
  # @param fields_to_check [Set<Field>] Menge der Felder, aus der die größte zusammenhängende Menge ermittelt werden soll.
  # @param current_biggest_swarm [Set<Field>] Aktuell größte zusammenhängende Feldmenge. Für rekursiven Aufruf.
  # @return [Set<Field>]
  def self.greatest_swarm_from_fields(board, fields_to_check, current_biggest_swarm = Set.new)
    # stop searching when the size of the current found biggest set is bigger than the rest of the fields
    return current_biggest_swarm if current_biggest_swarm.size > fields_to_check.size

    # start a new set of adjacent fields with the first field in fields_to_check
    current_swarm = Set.new
    field = fields_to_check.to_a.first
    fields_to_check.delete(field)
    current_swarm.add(field)

    # move all adjacent fields to the set
    loop do
      to_add = current_swarm
               .map { |f| GameRuleLogic.neighbours(board, f) }
               .flatten
               .select { |f| fields_to_check.include? f }
      break if to_add.empty?
      fields_to_check -= to_add
      current_swarm += to_add
    end

    # keep trying to find bigger sets
    if current_swarm.size > current_biggest_swarm.size
      GameRuleLogic.greatest_swarm_from_fields(
        board, fields_to_check, current_swarm
      )
    else
      GameRuleLogic.greatest_swarm_from_fields(
        board, fields_to_check, current_biggest_swarm
      )
    end
  end
end
