# coding: utf-8

require_relative 'field_type'
require_relative 'card_type'

# All methods which define the game rules. Needed for checking validity of moves
# and performing them.
class GameRules

   # Berechnet wie viele Karotten für einen Zug der länge
   # <code>moveCount</code> benötigt werden.
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
    # bei 30 Runden koennen nur 990 Karotten gesammelt werden
    return 44 if carrots >= 990
    return 0 if carrots < 1
    (Math.sqrt(2 * carrots + 1/4) - 1/2).round
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
  # @return [true, ''] falls ein Vorwärtszug möglich ist, [false, M] falls nicht, wobei M ein String mit einer Begruendung ist
  def self.is_valid_to_advance(state, distance)
    return false, 'Ein Vorwärtszug benötigt eine Mindestdistanz von einem Feld.' if distance <= 0
    player = state.current_player
    return false, 'Es muss ein Salat gegessen werden, bevor ein Vorwärtszug gemacht werden kann.' if must_eat_salad(state)
    required_carrots = GameRules.calculate_carrots(distance)
    return false, "Nicht genug Karotten, um #{distance} Felder vorwärts zu ziehen (Vorrat: #{player.carrots}, benötigt: #{required_carrots}" if (required_carrots > player.carrots)
    new_position = player.index + distance
    return false, 'Zielfeld wird von anderem Spieler besetzt.' if state.occupied_by_other_player?(state.field(new_position))
    case state.field(new_position).type
      when FieldType::INVALID
        return false, "Zielfeld #{new_position} ist nicht vorhanden."
      when FieldType::SALAD
        return false, 'Ohne Salat darf ein Salatfeld nicht betreten werden.' if player.salads < 1
      when FieldType::HARE
        state2 = state.deep_clone
        state2.set_last_action(Advance.new(distance))
        state2.current_player.index = new_position
        state2.current_player.carrots -= required_carrots
        return false, 'Auf ein Hasenfeld darf nur gezogen werden, wenn eine Karte gespielt werden kann' unless can_play_any_card(state2)
      when FieldType::GOAL
        carrotsLeft = player.carrots - required_carrots
        return false, "Auf das Zielfeld darf nur mit maximal 10 Karotten gezogen werden (es sind aber #{carrotsLeft} bei Erreichen des Zielfeldes)." unless carrotsLeft <= 10
        return false, "Auf das Zielfeld darf nur ohne Salate gezogen werden (es sind aber #{player.salads} übrig)." unless player.salads == 0
      when FieldType::HEDGEHOG
        return false, 'Auf ein Igelfeld darf nicht vorwärts gezogen werden.'
      when FieldType::CARROT, FieldType::POSITION_1, FieldType::START, FieldType::POSITION_2
        return true, ''
      else
        raise "Unknown Type #{state.field(new_position).type.inspect}"
    end
    return true, ''
  end

  # Überprüft, ob ein Spieler aussetzen darf. Er darf dies, wenn kein anderer Zug möglich ist.
  # @param state GameState
  # @return true, falls der derzeitige Spieler keine andere Aktion machen kann.
  def self.is_valid_to_skip(state)
    return !GameRules.can_do_anything(state)
  end

  # Überprüft, ob ein Spieler einen Zug (keinen Aussetzug)
  # @param state GameState
  # @return true, falls ein Zug möglich ist.
  def self.can_do_anything(state)
    return can_play_any_card(state) || is_valid_to_fall_back(state)[0] ||
           is_valid_to_exchange_carrots(state, 10)[0] ||
           is_valid_to_exchange_carrots(state, -10)[0] ||
           is_valid_to_eat(state)[0] || can_advance_to_any_field(state)
  end

  # Überprüft ob der derzeitige Spieler zu irgendeinem Feld einen Vorwärtszug machen kann.
  # @param state GameState
  # @return true, falls der Spieler irgendeinen Vorwärtszug machen kann
  def self.can_advance_to_any_field(state)
    fields = calculate_movable_fields(state.getCurrentPlayer().getCarrots())
    (0..fields).to_a.any? do |i|
      is_valid_to_advance(state, i)[0]
    end
  end

  # Überprüft <code>EatSalad</code> Züge auf Korrektheit. Um einen Salat
  # zu verzehren muss der Spieler sich:
  #
  # - auf einem Salatfeld befinden
  # - noch mindestens einen Salat besitzen
  # - vorher kein Salat auf diesem Feld verzehrt wurde
  #
  # @param state GameState
  # @return [true, ''], falls ein Salad gegessen werden darf, [false, M] falls nicht, wobei M ein String mit dem Grund ist
  def self.is_valid_to_eat(state)
    return false, 'Salate dürfen nur auf Salatfeldern gegessen werden.' unless state.current_field.type == FieldType::SALAD
    return false, 'Spieler hat keine Salate mehr zum Essen.' if state.current_player.salads < 1
    return false, 'Spieler muss das Feld verlassen.' if player_must_advance(state)
    return true, ''
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
  # @return [true, ''], falls die durch n spezifizierte Aktion möglich ist, [false, M] falls nicht, wobei M ein String mit dem Grund ist
  def self.is_valid_to_exchange_carrots(state, n)
    player = state.current_player
    return false, "Karotten können nur auf einem Karottenfeld #{n > 0 ? 'genommen' : 'abgegeben'} werden" if state.board.field(player.index).type != FieldType::CARROT
    return true, '' if n == 10
    return false, 'Gültige Karottenzahlen sind 10 und -10.' unless n == -10
    return false, "Spieler hat keine 10 Karotten zum Abgeben (er hat #{player.carrots})." if player.carrots < 10
    return true, ''
  end

  # Überprüft <code>FallBack</code> Züge auf Korrektheit
  #
  # @param state GameState
  # @return [true, ''], falls der currentPlayer einen Rückzug machen darf, [false, M] falls nicht, wobei M ein String mit dem Grund ist.
  def self.is_valid_to_fall_back(state)
    return false, 'Spieler muss einen Salat fressen.' if must_eat_salad(state)
    target_field = state.previous_field_of_type(
      FieldType::HEDGEHOG, state.current_player.index
    )
    return false, 'Es gibt kein Igelfeld hinter dem Spieler.' if target_field.nil?
    return false, 'Das Igelfeld hinter dem Spieler ist besetzt.' if state.occupied_by_other_player?(target_field)
    return true, ''
  end

  # Überprüft ob der derzeitige Spieler die <code>FALL_BACK</code> Karte spielen darf.
  # @param state GameState
  # @return [true, ''], falls die <code>FALL_BACK</code> Karte gespielt werden darf, [false, M] falls nicht, wobei M ein String mit dem Grund ist.
  def self.is_valid_to_play_fall_back(state)
    player = state.current_player
    return false, 'Spieler muss einen Vorwärtszug machen.' if player_must_advance(state)
    return false, 'Karten können nur auf Hasenfeldern gespielt werden.' unless state.current_field.type == FieldType::HARE
    return false, 'Nur der erste Spieler darf die FALL_BACK Karte spielen.' unless state.is_first(player)
    return false, 'Spieler besitzt die Karte FALL_BACK nicht.' unless player.owns_card_of_type(CardType::FALL_BACK)

    next_pos = state.other_player.index - 1

    case state.field(next_pos).type
      when FieldType::INVALID
        return false, 'Durch Spielen der FALL_BACK Karte darf man nicht auf einem nicht vorhandenen Feld landen (also vor dem Start).'
      when FieldType::HEDGEHOG
        return false, 'Durch Spielen der FALL_BACK Karte darf man nicht auf einem Igelfeld landen.'
      when FieldType::SALAD
        return false, 'Spieler käme durch Spielen der FALL_BACK Kart auf ein Salatfeld, hat aber keine Salate.' if player.salads < 1
      when FieldType::HARE
        state2 = state.deep_clone
        state2.set_last_action(new Card(CardType::HURRY_AHEAD))
        state2.current_player.delete(CardType::FALL_BACK)
        return false, 'Spieler käme durch Spielen der FALL_BACK Kart auf ein Hasenfeld, kann aber dann keine weitere Karte mehr spielen.' unless can_play_any_card(state2)
      when FieldType::START
      when FieldType::CARROT
      when FieldType::POSITION_1
      when FieldType::POSITION_2
        return true, ''
      when FieldType::GOAL
        raise 'Player got onto goal by playing a fall back card. This should never happen.'
      else
        raise "Unknown Type #{state.field(next_pos).type.inspect}"
    end
    return true, ''
  end

  # Überprüft ob der derzeitige Spieler die <code>HURRY_AHEAD</code> Karte spielen darf.
  # @param state GameState
  # @return [true, ''], falls die <code>HURRY_AHEAD</code> Karte gespielt werden darf, [false, M], falls nicht, wobei M ein String mit dem Grund ist.
  def self.is_valid_to_play_hurry_ahead(state)
    player = state.current_player
    return false, 'Spieler muss einen Vorwärtszug machen.' if player_must_advance(state)
    return false, 'Karten können nur auf Hasenfeldern gespielt werden.' unless state.current_field.type == FieldType::HARE
    return false, 'Nur der zweite Spieler darf die HURRY_AHEAD Karte spielen.' unless state.is_second(player)
    return false, 'Spieler besitzt die Karte HURRY_AHEAD nicht.' unless player.owns_card_of_type(CardType::HURRY_AHEAD)

    o = state.other_player
    next_pos = o.index + 1

    case state.field(next_pos).type
      when FieldType::INVALID
        return false, 'Durch Spielen der HURRY_AHEAD Karte darf man nicht auf einem nicht vorhandenen Feld landen (also nach dem Ziel).'
      when FieldType::HEDGEHOG
        return false, 'Durch Spielen der HURRY_AHEAD Karte darf man nicht auf einem Igelfeld landen.'
      when FieldType::SALAD
        return false, 'Spieler käme durch Spielen der HURRY_AHEAD Kart auf ein Salatfeld, hat aber keine Salate.' if player.salads < 1
      when FieldType::HARE
        state2 = state.deep_clone
        state2.set_last_action(new Card(CardType::HURRY_AHEAD))
        state2.current_player.delete(CardType::HURRY_AHEAD)
        return false, 'Spieler käme durch Spielen der HURRY_AHEAD Kart auf ein Hasenfeld, kann aber dann keine weitere Karte mehr spielen.' unless can_play_any_card(state2)
      when FieldType::GOAL
        return false, 'Spieler käme durch Spielen der HURRY_AHEAD Kart ins Ziel, darf es aber nicht betreten (entweder noch Salate oder mehr als 10 Karotten).' unless can_enter_goal(state)
      when FieldType::CARROT
      when FieldType::POSITION_1
      when FieldType::POSITION_2
        return true, ''
      when FieldType::START
        raise 'Player got onto start field by playing a hurry ahead card. This should never happen.'
      else
        raise "Unknown Type #{state.field(next_pos).type.inspect}"
    end
    return true, ''
  end

  # Überprüft ob der derzeitige Spieler die <code>TAKE_OR_DROP_CARROTS</code> Karte spielen darf.
  # @param state GameState
  # @param n 20 für nehmen, -20 für abgeben, 0 für nichts tun
  # @return [true, ''], falls die <code>TAKE_OR_DROP_CARROTS</code> Karte gespielt werden darf, [false, M], falls nicht, wobei M ein String mit dem Grund ist.
  def self.is_valid_to_play_take_or_drop_carrots(state, n)
    player = state.current_player
    return false, 'Spieler muss einen Vorwärtszug machen.' if player_must_advance(state)
    return false, 'Karten können nur auf Hasenfeldern gespielt werden.' unless state.current_field.type == FieldType::HARE
    return false, 'Spieler besitzt die Karte TAKE_OR_DROP_CARROTS nicht.' unless player.owns_card_of_type(CardType::TAKE_OR_DROP_CARROTS)
    return false, "#{n} ist keine erlaubte Anzahl beim Spielen der Karte TAKE_OR_DROP_CARROTS (erlaubt sind 20, -20 und 0)." unless [20, -20, 0].include?(n)
    return true, '' if n >= 0
    # at this point, n has to be -20
    return false, "Spieler hat keine 20 Karotten zum Abgeben (er hat #{player.carrots})." if player.carrots < 20
    return true, ''
  end

  # Überprüft ob der derzeitige Spieler die <code>EAT_SALAD</code> Karte spielen darf.
  # @param state GameState
  # @return (true, ''), falls die <code>EAT_SALAD</code> Karte gespielt werden darf, (false, M) falls nicht, wobei M ein String mit dem Grund ist
  def self.is_valid_to_play_eat_salad(state)
    player = state.current_player
    return false, 'Es muss vorwärts gezogen werden.' if player_must_advance(state)
    return false, 'Karten können nur auf Hasenfeldern gespielt werden.' unless state.current_field.type == FieldType::HARE
    return false, 'Spieler besitzt die Karte nicht.' unless player.owns_card_of_type(CardType::EAT_SALAD)
    return false, 'Spieler hat keine Salate zum Essen' if player.salads < 1
    return true, ''
  end

  # Überprüft ob der derzeitige Spieler irgendeine Karte spielen kann.
  # TAKE_OR_DROP_CARROTS wird nur mit 20 überprüft
  # @param state GameState
  # @return true, falls das Spielen einer Karte möglich ist
  def self.can_play_any_card(state)
    valid = false
    player = state.current_player

    player.cards.any? do |card|
      case card
        when CardType::EAT_SALAD
          is_valid_to_play_eat_salad(state)[0]
        when CardType::FALL_BACK
          is_valid_to_play_fall_back(state)[0]
        when CardType::HURRY_AHEAD
          is_valid_to_play_hurry_ahead(state)[0]
        when CardType::TAKE_OR_DROP_CARROTS
          is_valid_to_play_take_or_drop_carrots(state, 20)[0]
        else
          raise "Unknown CardType " + card
      end
    end
  end

  # Überprüft ob der derzeitige Spieler die Karte spielen kann.
  # @param state
  # @param c Karte die gespielt werden soll
  # @param n Parameter mit dem TAKE_OR_DROP_CARROTS überprüft wird, default 0
  # @return true, falls das Spielen der entsprechenden karte möglich ist
  def self.is_valid_to_play_card(state, c, n = 0)
    case c
      when CardType::EAT_SALAD
        isValidToPlayEatSalad(state)[0]
      when CardType::FALL_BACK
        is_valid_to_play_fall_back(state)[0]
      when CardType::HURRY_AHEAD
        is_valid_to_play_hurry_ahead(state)[0]
      when CardType::TAKE_OR_DROP_CARROTS
        is_valid_to_play_take_or_drop_carrots(state, n)[0]
      else
        raise "Unknown CardType " + c
    end
  end

  def self.must_eat_salad(state)
    player = state.current_player
    # check whether player just moved to salad field and must eat salad
    field = state.board.field(player.index)
    if field.type == FieldType::SALAD
      if player.last_non_skip_action&.is_a(Advance)
        return true
      elsif player.last_non_skip_action&.is_a(Card)
        card_action = player.last_non_skip_action
        if card_action.card_type == CardType::FALL_BACK ||
            card_action.card_type == CardType::HURRY_AHEAD
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
