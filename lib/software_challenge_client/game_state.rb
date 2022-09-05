# frozen_string_literal: true

require_relative './util/constants'
require_relative 'player'
require_relative 'board'
require_relative 'condition'

# Ein Spielzustand. Wird vom Server an die Computerspieler übermittelt und
# enthält alles, was der Computerspieler wissen muss, um einen Zug zu machen.
#
# Um eine Liste der gerade möglichen Züge zu bekommen, gibt es die Methode
# {GameState#possible_moves}.
class GameState
  # @!attribute [rw] turn
  # @return [Integer] Aktuelle Zugnummer (von 0 beginnend)
  attr_accessor :turn

  # @!attribute [r] player_one
  # @return [Player] Der erste Spieler
  attr_reader :player_one

  # @!attribute [r] player_two
  # @return [Player] Der zweite Spieler
  attr_reader :player_two

  # @!attribute [rw] start_player
  # @return [Player] Der Spieler der zuerst zieht
  attr_accessor :start_player

  # @!attribute [rw] board
  # @return [Board] Das aktuelle Spielbrett
  attr_accessor :board

  # @!attribute [rw] current_player
  # @return [Player] Der Spieler, der akutell dran ist
  attr_accessor :current_player

  # @!attribute [rw] myself_player
  # @return [Player] Der Spieler, der von diesem Skript gesteuert wird
  attr_accessor :myself_player

  # @!attribute [rw] condition
  # @return [Condition] Gewinner und Gewinngrund, falls das Spiel bereits
  #                     entschieden ist, sonst nil.
  attr_accessor :condition

  # Zugriff auf ein Feld des Spielbrettes. Siehe {Board#field}.
  def field(x, y)
    board.field(x, y)
  end

  # Erstellt einen neuen leeren Spielstand.
  def initialize
    @board = Board.new
    @turn = 0
  end

  # Fügt einen Spieler zum Spielzustand hinzu.
  #
  # @param player [Player] Der hinzuzufügende Spieler.
  def add_player(player)
    case player.team
    when Team::ONE
      @player_one = player
    when Team::TWO
      @player_two = player
    end
  end

  # @return [Player] Spieler, der gerade nicht an der Reihe ist.
  def other_player
    current_player == player_one ? player_two : player_one
  end

  # @return [Player] Der Spieler, der nicht p ist.
  def not_player(p)
    if p == player_one
      player_two
    else
      player_one
    end
  end

  # @return [Team] Typ des Spielers, der gerade nicht an der Reihe ist.
  def other_team
    other_player.type
  end

  # Findet den Spieler für ein Team.
  #
  # @param team [Team] Das Team
  # @return [Player] Der zugehörige Spieler
  def player_from_team(team)
    if team == Team::ONE
      @player_one
    else
      @player_two
    end
  end

  # @return [Integer] Aktuelle Rundennummer (von 1 beginnend)
  def round
    turn / 2 + 1
  end

  # @return [Bool] Ob diese gamestate in der ersten Runde ist
  def is_first_round?
    round == 1
  end

  # Führt einen Zug auf dem Spielzustand aus. Das Spielbrett wird entsprechend
  # modifiziert.
  #
  # @param move [Move] Der auszuführende Zug.
  def perform!(move)
    GameRuleLogic.perform_move(self, move)
  end

  # Überprüft ob der gegebene Spieler ziehen könnte oder blockiert ist
  #
  # @param player [Player] Der Spieler.
  # @return [Boolean] true, falls der Spieler ziehen könnte
  def can_move?(player)
    can = false

    for f in board.fields_of_team(player.team) do
      n = board.neighbors_of(f)
      can &= n.any? { |x| x.free? }
    end

    can
  end

  # @return [Boolean] true, falls das Spiel bereits geendet hat, false bei noch
  #                   laufenden Spielen.
  def game_ended?
    !condition.nil?
  end

  # @return [Player] Der Spieler, der das Spiel gewonnen hat, falls dies schon
  #                  entschieden ist. Sonst false.
  def winner
    condition.nil? ? nil : condition.winner
  end

  # @return [String] Der Grund, warum das Spiel beendet wurde, nil falls das
  #                  Spiel noch läuft.
  def winning_reason
    condition.nil? ? nil : condition.reason
  end

  # Ermittelt die Punkte eines Spielers. Wenn das Spiel durch Erreichen des
  # Rundenlimits beendet wird, hat der Spieler mit den meisten Punkten gewonnen.
  #
  # @param player [Player] Der Spieler, dessen Punkte berechnet werden sollen.
  # @return [Integer] Die Punkte des Spielers
  def points_for_player(player)
    player.nil? ? 0 : player.fishes
  end

  # TODO: Fix
  def ==(other)
    turn == other.turn &&
      myself_player == other.myself_player &&
      current_player == other.current_player &&
      blue == other.blue &&
      yellow == other.yellow &&
      red == other.red &&
      green == other.green &&
      board == other.board &&
      lastMove == other.lastMove &&
      condition == other.condition
  end

  # Erzeugt eine Kopie des Spielzustandes. Änderungen an dieser Kopie
  # beeinflussen den originalen Spielzustand nicht. Die Kopie kann also zum
  # testen von Spielzügen genutzt werden.
  def clone
    Marshal.load(Marshal.dump(self))
  end

  # @return [Array<Field>] Alle Felder mit Blöcken des Spielers, der gerade an der Reihe ist.
  def own_fields
    board.fields_of_team(current_player.team)
  end
end
