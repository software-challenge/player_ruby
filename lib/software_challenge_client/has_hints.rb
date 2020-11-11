# frozen_string_literal: true
module HasHints
  # @!attribute [r] hints
  # @return [Array<DebugHint>] Hinweise, die an den Zug angeheftet werden sollen. Siehe {DebugHint}.
  attr_reader :hints

  # @param hint [DebugHint]
  def add_hint(hint)
    @hints.push(hint)
  end
end
