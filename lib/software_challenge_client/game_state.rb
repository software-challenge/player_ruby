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
  # @!attribute [rw] round
  # @return [Integer] Aktuelle Rundennummer (von 1 beginnend)
  attr_accessor :round

  # @!attribute [rw] startColor
  # @return [Color] Die Farbe, die zuerst legen darf
  attr_accessor :start_color
  # @!attribute [rw] current_color_index
  # @return [Color] Der jetzige Index in der Zug Reihenfolge der Farben.
  attr_accessor :current_color_index
  # @!attribute [rw] ordered_colors
  # @return [Array<Color>] Ein Array aller Farben die ziehen können in 
  #                        der Reihenfolge in der sie drankommen
  attr_accessor :ordered_colors

  # @!attribute [r] undeployed_blue_pieces
  # @return [Array<PieceShape>] Die blauen, nicht gesetzten Spielsteine
  attr_accessor :undeployed_blue_pieces

  # @!attribute [r] undeployed_yellow_pieces
  # @return [Array<PieceShape>] Die gelben, nicht gesetzten Spielsteine
  attr_accessor :undeployed_yellow_pieces

  # @!attribute [r] undeployed_red_pieces
  # @return [Array<PieceShape>] Die roten, nicht gesetzten Spielsteine
  attr_accessor :undeployed_red_pieces

  # @!attribute [r] undeployed_green_pieces
  # @return [Array<PieceShape>] Die grünen, nicht gesetzten Spielsteine
  attr_accessor :undeployed_green_pieces

  # @!attribute [r] player_one
  # @return [Player] Der erste Spieler
  attr_reader :player_one
  # @!attribute [r] player_two
  # @return [Player] Der zweite Spieler
  attr_reader :player_two
  # @!attribute [rw] board
  # @return [Board] Das aktuelle Spielbrett
  attr_accessor :board
  # @!attribute [rw] startPiece
  # @return [PieceShape] Der Stein, der im ersten Zug von allen Farben gelegt werden muss
  attr_accessor :start_piece
  # @!attribute [rw] last_move
  # @return [Move] Der zuletzt gemachte Zug (ist nil vor dem ersten Zug, also
  #                bei turn == 0)
  attr_accessor :last_move
  # @!attribute [rw] condition
  # @return [Condition] Gewinner und Gewinngrund, falls das Spiel bereits
  #                     entschieden ist, sonst nil.
  attr_accessor :condition

  # Zugriff auf ein Feld des Spielbrettes. Siehe {Board#field}.
  def field(x, y)
    board.field(x, y)
  end

  def initialize
    @current_color = Color::RED
    @start_color = Color::RED
    @board = Board.new
    @turn = 0
    @undeployed_blue_pieces = PieceShape.to_a
    @undeployed_yellow_pieces = PieceShape.to_a
    @undeployed_red_pieces = PieceShape.to_a
    @undeployed_green_pieces = PieceShape.to_a
    @start_piece = GameRuleLogic.get_random_pentomino
  end

  # Fügt einen Spieler zum Spielzustand hinzu.
  #
  # @param player [Player] Der hinzuzufügende Spieler.
  def add_player(player)
    if player.type == PlayerType::ONE
      @player_one = player
    elsif player.type == PlayerType::TWO
      @player_two = player
    end
  end

  # @return [Player] Spieler, der gerade an der Reihe ist.
  def current_player
    turn % 2 == 0 ? player_one : player_two
  end

  # @return [Player] Spieler, der gerade nicht an der Reihe ist.
  def other_player
    turn % 2 == 0 ? player_two : player_one
  end

  # @return [PlayerType] Typ des Spielers, der gerade nicht an der Reihe ist.
  def other_player_type
    other_player.type
  end

  # @return [Color] Farbe, der gerade an der Reihe ist.
  def current_color
    ordered_colors[current_color_index]
  end

  # @return [Array<PieceShape>] Array aller Shapes, der gegebenen Farbe, die noch nicht gelegt wurden
  def undeployed_pieces(color)
    case color
    when Color::RED
      undeployed_red_pieces
    when Color::BLUE
      undeployed_blue_pieces
    when Color::YELLOW
      undeployed_yellow_pieces
    when Color::GREEN
      undeployed_green_pieces
    end
  end

  # @return [Array<PieceShape>] Array aller Shapes, der gegebenen Farbe, die schon gelegt wurden
  def deployed_pieces(color)
    board.deployed_pieces(color)
  end

  # @return [Bool] Ob diese gamestate in der ersten Runde ist
  def is_first_move?
    round == 1
  end

  # Führt einen Zug auf dem Spielzustand aus. Das Spielbrett wird entsprechend
  # modifiziert.
  #
  # @param move [Move] Der auszuführende Zug.
  def perform!(move)
    GameRuleLogic.perform_move(self, move)
  end

  # @return [Boolean] true, falls das Spiel bereits geendet hat, false bei noch
  #                   laufenden Spielen.
  def game_ended?
    !condition.nil?
  end

  # Entfernt die jetzige Farbe aus der Farbrotation 
  def remove_active_color
    ordered_colors.delete current_color
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
  def points_for_player(_player)
    # TODO
    -1
  end

  def ==(other)
    turn == other.turn &&
      start_color == other.start_color &&
      current_color == other.current_color &&
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

  # Wechselt den Spieler, der aktuell an der Reihe ist.
  def switch_current_player
    @current_player_color = other_player_color
  end

  # @return [Array<Field>] Alle Felder mit Blöcken des Spielers, der gerade an der Reihe ist.
  def own_fields
    board.fields_of_color(current_color)
  end
end
