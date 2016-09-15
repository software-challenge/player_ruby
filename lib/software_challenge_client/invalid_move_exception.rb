# encoding: UTF-8
class InvalidMoveException < StandardError
  def initialize(msg, move_or_action)
    # This exception will be thrown by a move or by an individual action,
    # depending where the rule violation was detected.
    @move_or_action = move_or_action
    super(msg)
  end

  def message
    "#{super}: #{@move_or_action}"
  end
end