# encoding: utf-8

# Das Interface sollte von einem Client implementiert werden, damit er über das
# Gem an einem Spiel teilnehmen kann.
class ClientInterface
  # Wird automatisch aktualisiert und ist immer der Spielzustand des aktuellen Zuges.
  attr_accessor :gamestate

  # Wird aufgerufen, wenn der Client einen Zug machen soll. Dies ist der
  # Einstiegspunkt für die eigentliche Logik des Computerspielers. Er muss auf
  # Basis des Spielzustandes entscheiden, welchen Zug er machen möchte und diese
  # zurückgeben.
  #
  # @return [Move] Ein für den aktuellen Spielzustand gültiger Spielzug.
  def move_requested
    raise 'Not yet implemented'
  end
end
