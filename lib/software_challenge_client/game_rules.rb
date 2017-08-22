# coding: utf-8

require_relative 'field_type'
require_relative 'card_type'

# All methods which define the game rules. Needed for checking validity of moves
# and performing them.
class GameRules

   # Berechnet wie viele Karotten für einen Zug der länge
   # <code>moveCount</code> benötigt werden. Entspricht den Veränderungen des
   # Spieleabends der CAU.
   #
   # @param moveCount Anzahl der Felder, um die bewegt wird
   # @return Anzahl der benötigten Karotten
  def self.calculate_carrots(moveCount)
    (moveCount * (moveCount + 1)) / 2
  end

  # Berechnet, wieviele Züge mit <code>carrots</code> Karotten möglich sind.
  #
  # @param carrots maximal ausgegebene Karotten
  # @return Felder um die maximal bewegt werden kann
  def self.calculate_movable_fields(carrots)
    return 44 if carrots >= 990
    return 0 if carrots < 1
    (sqrt(2.0 * carrots + 0.25) - 0.48).round # -0.48 anstelle von -0.5 um Rundungsfehler zu vermeiden
  end

  # Überprüft <code>Advance</code> Aktionen auf ihre Korrektheit. Folgende
  # Spielregeln werden beachtet:
  #
  # - Der Spieler muss genügend Karotten für den Zug besitzen
  # - Wenn das Ziel erreicht wird, darf der Spieler nach dem Zug maximal 10 Karotten übrig haben
  # - Man darf nicht auf Igelfelder ziehen
  # - Salatfelder dürfen nur betreten werden, wenn man noch Salate essen muss
  # - Hasenfelder dürfen nur betreten werden, wenn man noch Hasenkarten ausspielen kann
  #
  # @param state GameState
  # @param distance relativer Abstand zur aktuellen Position des Spielers
  # @return true, falls ein Vorwärtszug möglich ist
  def self.is_valid_to_advance(state, distance)
    return false if distance <= 0
    player = state.current_player
    return false if must_eat_salad(state)
    valid = true
    required_carrots = GameRules.calculate_carrots(distance)
    valid = valid && (required_carrots <= player.carrots)

    new_position = player.index + distance
    valid = valid && !state.occupied_by_other_player?(state.fields[new_position])
    case state.fields[new_position].type
      when FieldType::INVALID
        valid = false
      when FieldType::SALAD
        valid = valid && player.salads > 0
      when FieldType::HARE
        state2 = state.clone()
        state2.set_last_action(Advance.new(distance))
        state2.current_player.index = new_position
        state2.current_player.carrots -= required_carrots
        valid = valid && can_play_any_card(state2)
      when FieldType::GOAL
        carrotsLeft = player.carrots - required_carrots
        valid = valid && carrotsLeft <= 10
        valid = valid && player.salads == 0
      when FieldType::HEDGEHOG
        valid = false
      when FieldType::CARROT, FieldType::POSITION_1, FieldType::START, FieldType::POSITION_2
        # do nothing
      else
        raise "Unknown Type #{state.fields[new_position].type.inspect}"
    end
    return valid
  end

  # Überprüft, ob ein Spieler aussetzen darf. Er darf dies, wenn kein anderer Zug möglich ist.
  # @param state GameState
  # @return true, falls der derzeitige Spieler keine andere Aktion machen kann.
  def self.isValidToSkip(state)
    return !GameRules.canDoAnything(state)
  end

  # Überprüft, ob ein Spieler einen Zug (keinen Aussetzug)
  # @param state GameState
  # @return true, falls ein Zug möglich ist.
  def self.canDoAnything(state)
    return can_play_any_card(state) || isValidToFallBack(state) ||
           isValidToExchangeCarrots(state, 10) ||
           isValidToExchangeCarrots(state, -10) ||
           is_valid_to_eat(state) || canAdvanceToAnyField(state)
  end

  # Überprüft ob der derzeitige Spieler zu irgendeinem Feld einen Vorwärtszug machen kann.
  # @param state GameState
  # @return true, falls der Spieler irgendeinen Vorwärtszug machen kann
  def self.canAdvanceToAnyField(state)
    fields = calculate_movable_fields(state.getCurrentPlayer().getCarrots())
    (0..fields).to_a.each do |i|
      return true if isValidToAdvance(state, i)
    end
    return false
  end

  # Überprüft <code>EatSalad</code> Züge auf Korrektheit. Um einen Salat
  # zu verzehren muss der Spieler sich:
  #
  # - auf einem Salatfeld befinden
  # - noch mindestens einen Salat besitzen
  # - vorher kein Salat auf diesem Feld verzehrt wurde
  #
  # @param state GameState
  # @return true, falls ein Salad gegessen werden darf
  def self.is_valid_to_eat(state)
    state.current_field.type == FieldType::SALAD &&
        state.current_player.salads > 0 &&
        !player_must_advance(state)
  end

  # Überprüft ab der derzeitige Spieler im nächsten Zug einen Vorwärtszug machen muss.
  # @param state GameState
  # @return true, falls der derzeitige Spieler einen Vorwärtszug gemacht werden muss
  def self.player_must_advance(state)
    player = state.current_player
    type = state.board.field(player.index).type

    return true if (type == FieldType::HEDGEHOG || type == FieldType::START)

    last_action = state.current_player.last_non_skip_action

    if (!last_action.nil?)
      if (last_action.kind_of? EatSalad)
        return true
      elsif (last_action.kind_of? Card)
        # the player has to leave a rabbit field in next turn
        if (last_action.type == CardType::EAT_SALAD)
          return true
        elsif (last_action.type == CardType::TAKE_OR_DROP_CARROTS) # the player has to leave the rabbit field
          return true
        end
      end
    end

    return false
  end

  # Überprüft ob der derzeitige Spieler 10 Karotten nehmen oder abgeben kann.
  # @param state GameState
  # @param n 10 oder -10 je nach Fragestellung
  # @return true, falls die durch n spezifizierte Aktion möglich ist.
  def self.is_valid_to_exchange_carrots(state, n)
    player = state.current_player
    return false if state.board.field(player.index).type != FieldType::CARROT
    return true if n == 10
    return (player.carrots >= 10) if n == -10
  end

  # Überprüft <code>FallBack</code> Züge auf Korrektheit
  #
  # @param state GameState
  # @return true, falls der currentPlayer einen Rückzug machen darf
  def self.is_valid_to_fall_back(state)
    return false if (must_eat_salad(state))
    valid = true
    target_field = state.get_previous_field_by_type(
      FieldType::HEDGEHOG, state.current_player.index
    )
    !target_field.nil? && !state.occupied_by_other_player?(target_field)
  end

  # Überprüft ob der derzeitige Spieler die <code>FALL_BACK</code> Karte spielen darf.
  # @param state GameState
  # @return true, falls die <code>FALL_BACK</code> Karte gespielt werden darf
  def self.is_valid_to_play_fall_back(state)
    player = state.current_player
    valid = !player_must_advance(state) &&
        state.current_field.type == FieldType::HARE &&
        state.is_first(player) &&
        player.owns_card_of_type(CardType::FALL_BACK)

    next_pos = state.other_player.index - 1

    case state.fields[next_pos].type
      when FieldType::INVALID, FieldType::HEDGEHOG
        valid = false
      when FieldType::SALAD
        valid = valid && player.salads > 0
      when FieldType::HARE
        state2 = state.clone()
        state2.set_last_action(new Card(CardType::HURRY_AHEAD))
        state2.current_player.delete(CardType::FALL_BACK)
        valid = valid && can_play_any_card(state2)
      when FieldType::START
      when FieldType::CARROT
      when FieldType::POSITION_1
      when FieldType::POSITION_2
        # do nothing
      else
        raise "Unknown Type #{state.fields[next_pos].type.inspect}"
    end
    return valid
  end

  # Überprüft ob der derzeitige Spieler die <code>HURRY_AHEAD</code> Karte spielen darf.
  # @param state GameState
  # @return true, falls die <code>HURRY_AHEAD</code> Karte gespielt werden darf
  def self.is_valid_to_play_hurry_ahead(state)
    player = state.current_player
    valid = !player_must_advance(state) &&
      state.current_field.type == FieldType::HARE &&
      state.is_second(player) &&
      player.owns_card_of_type(CardType::HURRY_AHEAD)

    o = state.other_player
    next_pos = o.index + 1

    case state.fields[next_pos].type
      when FieldType::INVALID, FieldType::HEDGEHOG
        valid = false
      when FieldType::SALAD
        valid = valid && player.salads > 0
      when FieldType::HARE
        state2 = state.clone()
        state2.set_last_action(new Card(CardType.HURRY_AHEAD))
        state2.current_player.cards.delete(CardType.HURRY_AHEAD)
        valid = valid && can_play_any_card(state2)
      when FieldType::GOAL
        valid = valid && can_enter_goal(state)
      when FieldType::CARROT
      when FieldType::POSITION_1
      when FieldType::POSITION_2
      when FieldType::START
        # do nothing
      else
        raise "Unknown Type #{state.fields[next_pos].type.inspect}"
    end
    return valid
  end

  # Überprüft ob der derzeitige Spieler die <code>TAKE_OR_DROP_CARROTS</code> Karte spielen darf.
  # @param state GameState
  # @param n 20 für nehmen, -20 für abgeben, 0 für nichts tun
  # @return true, falls die <code>TAKE_OR_DROP_CARROTS</code> Karte gespielt werden darf
  def self.is_valid_to_play_take_or_drop_carrots(state, n)
    player = state.current_player
    valid = !player_must_advance(state) &&
        state.current_field.type == FieldType::HARE &&
        player.owns_card_of_type(CardType::TAKE_OR_DROP_CARROTS)
    valid = valid && (n == 20 || n == -20 || n == 0)
    if (n < 0)
      valid = valid && ((player.getCarrots() + n) >= 0)
    end
    return valid
  end

  # Überprüft ob der derzeitige Spieler die <code>EAT_SALAD</code> Karte spielen darf.
  # @param state GameState
  # @return true, falls die <code>EAT_SALAD</code> Karte gespielt werden darf
  def self.is_valid_to_play_eat_salad(state)
    player = state.current_player
    !player_must_advance(state) &&
        state.current_field.type == FieldType::HARE &&
        player.owns_card_of_type(CardType::EAT_SALAD) &&
        player.salads > 0
  end

  # Überprüft ob der derzeitige Spieler irgendeine Karte spielen kann.
  # TAKE_OR_DROP_CARROTS wird nur mit 20 überprüft
  # @param state GameState
  # @return true, falls das Spielen einer Karte möglich ist
  def self.can_play_any_card(state)
    valid = false
    player = state.current_player

    player.cards.each do |card|
      case card
        when CardType::EAT_SALAD
          valid = valid || is_valid_to_play_eat_salad(state)
        when CardType::FALL_BACK
          valid = valid || is_valid_to_play_fall_back(state)
        when CardType::HURRY_AHEAD
          valid = valid || is_valid_to_play_hurry_ahead(state)
        when CardType::TAKE_OR_DROP_CARROTS
          valid = valid || is_valid_to_play_take_or_drop_carrots(state, 20)
        else
          raise "Unknown CardType " + card
      end
    end
    return valid
  end

  # Überprüft ob der derzeitige Spieler die Karte spielen kann.
  # @param state
  # @param c Karte die gespielt werden soll
  # @param n Parameter mit dem TAKE_OR_DROP_CARROTS überprüft wird
  # @return true, falls das Spielen der entsprechenden karte möglich ist
  def self.is_valid_to_play_card(state, c, n)
    valid
    case c
      when CardType::EAT_SALAD
        valid = isValidToPlayEatSalad(state)
      when CardType::FALL_BACK
        valid = is_valid_to_play_fall_back(state)
      when CardType::HURRY_AHEAD
        valid = is_valid_to_play_hurry_ahead(state)
      when CardType::TAKE_OR_DROP_CARROTS
        valid = is_valid_to_play_take_or_drop_carrots(state, n)
      else
        raise "Unknown CardType " + c
    end
    return valid
  end

  def self.must_eat_salad(state)
    player = state.current_player
    # check whether player just moved to salad field and must eat salad
    field = state.board.field(player.index)
    if (field.type == FieldType::SALAD)
      if (player.getLastNonSkipAction().is_a(Advance))
        return true
      elsif (player.getLastNonSkipAction().is_a(Card))
        if ((player.getLastNonSkipAction()).getType() == CardType::FALL_BACK ||
                (player.getLastNonSkipAction()).getType() == CardType::HURRY_AHEAD)
          return true
        end
      end
    end
    return false
  end

  # TODO difference isValidToPlayCard
  # @param state
  # @return
  def self.can_play_card(state)
    player = state.getCurrentPlayer()
    canPlayCard = state.getTypeAt(player.getFieldIndex()).equals(FieldType.HARE)
    player.getCards().each do |card|
      canPlayCard = canPlayCard || is_valid_to_play_card(state, card, 0)
    end
    return canPlayCard
  end

  # TODO difference isVAlidTOMove
  # @param state
  # @return
  def self.can_move(state)
    can_move = false
    max_distance = GameRules.calculate_movable_fields(state.getCurrentPlayer().getCarrots())
    (1..max_distance).to_a.each do |i|
      can_move = can_move || isValidToAdvance(state, i)
    end
    return can_move
  end

  # Überprüft ob eine Karte gespielt werden muss. Sollte nach einem
  # Zug eines Spielers immer false sein, ansonsten ist Zug ungültig.
  # @param state derzeitiger GameState
  def self.must_play_card(state)
    state.current_player.must_play_card
  end


  # Überprüft ob ein der derzeitige Spieler das Ziel betreten darf
  # @param state GameState
  # @return
  def self.can_enter_goal(state)
    player = state.current_player
    player.carrots <= 10 && player.salads == 0
  end

end
