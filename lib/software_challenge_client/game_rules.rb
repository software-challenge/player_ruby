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
  def self.calculateMoveableFields(carrots)
    moves = 0
    while (calculate_carrots(moves) <= carrots)
      moves += 1
    end
    return moves - 1
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
    if (distance <= 0)
      return false
    end
    player = state.current_player
    return false if (must_eat_salad(state))
    valid = true
    required_carrots = GameRules.calculate_carrots(distance)
    valid = valid && (required_carrots <= player.carrots)

    new_position = player.index + distance
    new_field = state.board.field(new_position)
    valid = valid && !state.occupied_by_other_player?(new_field)
    type = new_field.type
    case type
      when FieldType::INVALID
        valid = false
      when FieldType::SALAD
        valid = valid && player.salads > 0
      when FieldType::HARE
        GameState state2 = null
        state2 = state.clone()
        state2.setLastAction(new Advance(distance))
        state2.getCurrentPlayer().setFieldIndex(new_position)
        state2.getCurrentPlayer().changeCarrotsBy(-required_carrots)
        valid = valid && canPlayAnyCard(state2)
      when FieldType::GOAL
        int carrotsLeft = player.getCarrots() - required_carrots
        valid = valid && carrotsLeft <= 10
        valid = valid && player.getSalads() == 0
      when FieldType::HEDGEHOG
        valid = false
      when FieldType::CARROT, FieldType::POSITION_1, FieldType::START, FieldType::POSITION_2
        # do nothing
      else
        raise "Unknown Type " + type
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
    return canPlayAnyCard(state) || isValidToFallBack(state) ||
           isValidToExchangeCarrots(state, 10) ||
           isValidToExchangeCarrots(state, -10) ||
           isValidToEat(state) || canAdvanceToAnyField(state)
  end

  # Überprüft ob der derzeitige Spieler zu irgendeinem Feld einen Vorwärtszug machen kann.
  # @param state GameState
  # @return true, falls der Spieler irgendeinen Vorwärtszug machen kann
  def self.canAdvanceToAnyField(state)
    fields = calculateMoveableFields(state.getCurrentPlayer().getCarrots())
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
  def self.isValidToEat(state)
    player = state.getCurrentPlayer()
    valid = true
    currentField = state.getTypeAt(player.getFieldIndex())

    valid = valid && (currentField.equals(FieldType.SALAD))
    valid = valid && (player.getSalads() > 0)
    valid = valid && !playerMustAdvance(state)

    return valid
  end

  # Überprüft ab der derzeitige Spieler im nächsten Zug einen Vorwärtszug machen muss.
  # @param state GameState
  # @return true, falls der derzeitige Spieler einen Vorwärtszug gemacht werden muss
  def self.player_must_advance(state)
    player = state.current_player
    type = state.board.field(player.index).type

    return true if (type == FieldType::HEDGEHOG || type == FieldType::START)

    lastAction = state.getLastNonSkipAction(player)

    if (lastAction != null)
      if (lastAction instanceof EatSalad)
        return true
      elsif (lastAction instanceof Card)
        # the player has to leave a rabbit field in next turn
        if ((lastAction).getType() == CardType.EAT_SALAD)
          return true
        elsif ((lastAction).getType() == CardType.TAKE_OR_DROP_CARROTS) # the player has to leave the rabbit field
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
    target_field = state.previous_field_by_type(
      FieldType::HEDGEHOG, state.current_player.index
    )
    !target_field.nil? && !state.occupied_by_other_player?(target_field)
  end

  # Überprüft ob der derzeitige Spieler die <code>FALL_BACK</code> Karte spielen darf.
  # @param state GameState
  # @return true, falls die <code>FALL_BACK</code> Karte gespielt werden darf
  def self.isValidToPlayFallBack(state)
    player = state.getCurrentPlayer()
    valid = !playerMustAdvance(state) && state.isOnRabbitField() && state.isFirst(player)

    valid = valid && player.ownsCardOfTyp(CardType.FALL_BACK)

    o = state.getOpponent(player)
    nextPos = o.getFieldIndex() - 1

    type = state.getTypeAt(nextPos)
    case type
      when FieldType::INVALID, FieldType::HEDGEHOG
        valid = false
      when FieldType::SALAD
        valid = valid && player.getSalads() > 0
      when FieldType::HARE
        state2 = null
        state2 = state.clone()
        state2.setLastAction(new Card(CardType.HURRY_AHEAD))
        state2.getCurrentPlayer().setCards(player.getCardsWithout(CardType.FALL_BACK))
        valid = valid && canPlayAnyCard(state2)
      when FieldType::START
      when FieldType::CARROT
      when FieldType::POSITION_1
      when FieldType::POSITION_2
        # do nothing
      else
        raise "Unknown Type " + type
    end
    return valid
  end

  # Überprüft ob der derzeitige Spieler die <code>HURRY_AHEAD</code> Karte spielen darf.
  # @param state GameState
  # @return true, falls die <code>HURRY_AHEAD</code> Karte gespielt werden darf
  def self.isValidToPlayHurryAhead(state)
    player = state.getCurrentPlayer()
    valid = !playerMustAdvance(state) && state.isOnRabbitField() && !state.isFirst(player)
    valid = valid && player.ownsCardOfTyp(CardType.HURRY_AHEAD)

    Player o = state.getOpponent(player)
    nextPos = o.getFieldIndex() + 1

    type = state.getTypeAt(nextPos)
    case type
      when FieldType::INVALID, FieldType::HEDGEHOG
        valid = false
      when FieldType::SALAD
        valid = valid && player.getSalads() > 0
      when FieldType::HARE
        state2 = null
        state2 = state.clone()
        state2.setLastAction(new Card(CardType.HURRY_AHEAD))
        state2.getCurrentPlayer().setCards(player.getCardsWithout(CardType.HURRY_AHEAD))
        valid = valid && canPlayAnyCard(state2)
      when FieldType::GOAL
        valid = valid && canEnterGoal(state)
      when FieldType::CARROT
      when FieldType::POSITION_1
      when FieldType::POSITION_2
      when FieldType::START
        # do nothing
      else
        raise "Unknown Type " + type
    end
    return valid
  end

  # Überprüft ob der derzeitige Spieler die <code>TAKE_OR_DROP_CARROTS</code> Karte spielen darf.
  # @param state GameState
  # @param n 20 für nehmen, -20 für abgeben, 0 für nichts tun
  # @return true, falls die <code>TAKE_OR_DROP_CARROTS</code> Karte gespielt werden darf
  def self.isValidToPlayTakeOrDropCarrots(state, n)
    player = state.getCurrentPlayer()
    valid = !playerMustAdvance(state) && state.isOnRabbitField() && player.ownsCardOfTyp(CardType::TAKE_OR_DROP_CARROTS)
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
    return !player_must_advance(state) &&
           state.is_on_hare_field &&
           player.owns_card_of_type(CardType::EAT_SALAD) &&
           player.salads > 0
  end

  # Überprüft ob der derzeitige Spieler irgendeine Karte spielen kann.
  # TAKE_OR_DROP_CARROTS wird nur mit 20 überprüft
  # @param state GameState
  # @return true, falls das Spielen einer Karte möglich ist
  def self.canPlayAnyCard(state)
    valid = false
    player = state.getCurrentPlayer()

    player.getCards.each do |card|
      case card
        when CardType::EAT_SALAD
          valid = valid || isValidToPlayEatSalad(state)
        when CardType::FALL_BACK
          valid = valid || isValidToPlayFallBack(state)
        when CardType::HURRY_AHEAD
          valid = valid || isValidToPlayHurryAhead(state)
        when CardType::TAKE_OR_DROP_CARROTS
          valid = valid || isValidToPlayTakeOrDropCarrots(state, 20)
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
  def self.isValidToPlayCard(state, c, n)
    valid
    case c
      when CardType::EAT_SALAD
        valid = isValidToPlayEatSalad(state)
      when CardType::FALL_BACK
        valid = isValidToPlayFallBack(state)
      when CardType::HURRY_AHEAD
        valid = isValidToPlayHurryAhead(state)
      when CardType::TAKE_OR_DROP_CARROTS
        valid = isValidToPlayTakeOrDropCarrots(state, n)
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
  def self.canPlayCard(state)
    player = state.getCurrentPlayer()
    canPlayCard = state.getTypeAt(player.getFieldIndex()).equals(FieldType.HARE)
    player.getCards().each do |card|
      canPlayCard = canPlayCard || isValidToPlayCard(state, card, 0)
    end
    return canPlayCard
  end

  # TODO difference isVAlidTOMove
  # @param state
  # @return
  def self.canMove(state)
    canMove = false
    maxDistance = GameRules.calculateMoveableFields(state.getCurrentPlayer().getCarrots())
    (1..maxDistance).to_a.each do |i|
      canMove = canMove || isValidToAdvance(state, i)
    end
    return canMove
  end

  # Überprüft ob eine Karte gespielt werden muss. Sollte nach einem
  # Zug eines Spielers immer false sein, ansonsten ist Zug ungültig.
  # @param state derzeitiger GameState
  def self.mustPlayCard(state)
    return state.getCurrentPlayer().mustPlayCard()
  end


  # Überprüft ob ein der derzeitige Spieler das Ziel betreten darf
  # @param state GameState
  # @return
  def self.canEnterGoal(state)
    player = state.getCurrentPlayer()
    return player.getCarrots() <= 10 && player.getSalads() == 0
  end

end
