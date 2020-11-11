# encoding: utf-8
# frozen_string_literal: true

# Ein Hinweis, der zu einem Zug hinzugefügt werden kann. Z.B. zu
# Diagnosezwecken. Der Hinweis wird in der grafischen Oberfläche angezeigt und
# in Replay-Dateien gespeichert.
class DebugHint
  # @!attribute [r] content
  # @return [String] Der Text des Hinweises.
  attr_reader :content

  # Erstellt einen neuen Hinweis.
  # @param content [Object] Inhalt des Hinweises. Wird zu String konvertiert.
  def initialize(content)
    @content = content.to_s
  end
end
