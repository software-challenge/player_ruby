# encoding: utf-8
require_relative 'debug_hint'

# Ein Spielzug. Er ist definiert durch das Koordinatenpaar des Ausgangsfeldes (ein Fisch des Spielers, der den Zug machen will) und eine Bewegungsrichtung.
class Move
  # @!attribute [r] x
  # @return [Integer] X-Koordinate des Fisches, der bewegt werden soll. Die Spalte ganz links auf dem Spielbrett hat X-Koordinate 0, die ganz rechts 9.
  attr_reader :x

  # @!attribute [r] y
  # @return [Integer] Y-Koordinate des Fisches, der bewegt werden soll. Die Zeile ganz unten auf dem Spielbrett hat Y-Koordinate 0, die ganz oben 9.
  attr_reader :y

  # @!attribute [r] direction
  #
  # @return [Direction] Die Richtung, in die bewegt werden soll.
  attr_reader :direction

  # @!attribute [r] hints
  # @return [Array<DebugHint>] Hinweise, die an den Zug angeheftet werden sollen. Siehe {DebugHint}.
  attr_reader :hints

  # Erstellt einen neuen Zug.
  # @param x [Integer]
  # @param y [Integer]
  # @param direction [Direction]
  def initialize(x, y, direction)
    @x = x
    @y = y
    @direction = direction
    @hints = []
  end

  # @param hint [DebugHint]
  def add_hint(hint)
    @hints.push(hint)
  end

  def ==(other)
    x == other.x && y == other.y && direction == other.direction
  end

  def to_s
    "Move: (#{x},#{y}) #{direction}"
  end

  # @return [Coordinates] Die Koordinaten des Ausgangsfeldes des Zuges als Koordinatenpaar.
  def from_field
    Coordinates.new(x, y)
  end

  # Überprüft, ob der Zug in dem gegebenen Spielzustand regelkonform ausgeführt werden kann.
  # @param gamestate [GameState]
  # @return [Boolean]
  def valid?(gamestate)
    GameRuleLogic.valid_move(self, gamestate.board)
  end

  # Führt den Zug in dem gegebenen Spielzustand aus. Sollte dabei gegen Spielregeln verstossen werden, wird eine InvalidMoveException geworfen.
  # @param gamestate [GameState]
  def perform!(gamestate)
    if GameRuleLogic.valid_move(self, gamestate.board)
      type = gamestate.board.field(x, y).type
      gamestate.board.change_field(x, y, FieldType::EMPTY)
      target = GameRuleLogic.move_target(self, gamestate.board)
      gamestate.board.change_field(target.x, target.y, type)
    else
      raise InvalidMoveException.new('Invalid move', self)
    end
    # change the state to the next turn
    gamestate.last_move = self
    gamestate.turn += 1
    gamestate.switch_current_player
  end


  # Ermittelt die Koordinaten des Zielfeldes des Zuges mit einer gegebenen Zugweite.
  # @param speed [Integer] Die Zugweite. Entspricht normalerweise der Anzahl der Fische auf der Bewegungslinie.
  # @return [Coordinates] Koordinaten des Zielfeldes. Eventuell ausserhalb des Spielbrettes.
  def target_field(speed)
    direction.translate(from_field, speed)
  end
end
