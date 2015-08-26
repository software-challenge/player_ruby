require_relative './util/constants'
require_relative 'player'
require_relative 'board'
require_relative 'move'
require_relative 'condition'
require_relative 'player_color'
require_relative 'field_type'

# @author Ralf-Tobias Diekert
# The state of a game
class GameState
  
  # @!attribute [rw] turn
  # @return [Integer] turn number
  attr_accessor :turn
  # @!attribute [rw] startPlayerColor
  # @return [PlayerColor] the start-player's color
  attr_accessor :startPlayerColor
  # @!attribute [rw] currentPlayerColor
  # @return [PlayerColor] the current player's color
  attr_accessor :currentPlayerColor
  # @!attribute [r] red
  # @return [Player] the red player
  attr_reader :red
  # @!attribute [r] blue
  # @return [Player] the blue player
  attr_reader :blue
  # @!attribute [rw] board
  # @return [Board] the game's board
  attr_accessor :board
  # @!attribute [rw] lastMove
  # @return [Move] the last move, that was made
  attr_accessor :lastMove
  # @!attribute [rw] condition
  # @return [Condition] the winner and winning reason
  attr_accessor :condition
  
  def initialize
    self.currentPlayerColor = PlayerColor::RED
    self.startPlayerColor = PlayerColor::RED
    self.board = Board.new(true)
  end
  
  # adds a player to the gamestate
  #
  # @param player [Player] the player, that will be added
  def addPlayer(player) 
    if player.color == PlayerColor::RED 
      @red = player
    else if player.color == PlayerColor::BLUE
        @blue = player
      end
    end
  end

  # gets the current player
  #
  # @return [Player] the current player
  def currentPlayer
    if self.currentPlayerColor == PlayerColor::RED
      return self.red
    else
      return self.blue
    end
  end

  # gets the other (not the current) player
  # 
  # @return [Player] the other (not the current) player
  def otherPlayer
    if self.currentPlayerColor == PlayerColor::RED
      return self.blue 
    else
      return self.red
    end
  end
  
  # gets the other (not the current) player's color
  #
  # @return [PlayerColor] the other (not the current) player's color
  def otherPlayerColor
    return PlayerColor.opponentColor(self.currentPlayerColor)
  end
  
  # gets the start player
  #
  # @return [Player] the startPlayer
  def startPlayer
    if self.startPlayer == PlayerColor::RED 
      return self.red
    else
      return self.blue
    end
  end
  
  # switches current player
  def switchCurrentPlayer
    if currentPlayer.color == PlayerColor::RED
      @currentPlayer = self.blue
    else
      @currentPlayer = self.red
    end
  end
  
  # prepares next turn and sets the last move
  #
  # @param [Move] the last move
  def prepareNextTurn(lastMove)
    @turn++
    @lastMove = lastMove;
    self.switchCurrentPlayer()
  end
  
  # gets the current round
  #
  # @return [Integer] the current round
  def round
    return self.turn / 2
  end
  
  # gets all possible moves
  #
  # @return [Array<Move>] a list of all possible moves
  def getPossibleMoves
    enemyFieldType = currentPlayer.color == PlayerColor::RED ? FieldType::BLUE : FieldType::RED
    moves = Array.new
    for x in 0..(Constants::SIZE-1)
      for y in 0..(Constants::SIZE-1)
        if (self.board.fields[x][y].ownerColor == PlayerColor::NONE &&
              self.board.fields[x][y].type != FieldType::SWAMP &&
              self.board.fields[x][y].type != enemyFieldType)
          moves.push(Move.new(x, y))
        end
      end
    end
    return moves
  end
  
  # performs a move on the gamestate
  #
  # @param move [Move] the move, that will be performed
  # @param player [Player] the player, who makes the move
  def perform(move, player)
    if !move.nil?
      if move.x < Constants::SIZE && move.y < Constants::SIZE && 
          move.x >= 0 && move.y >= 0
        if self.getPossibleMoves.include?(move) 
          self.board.put(move.x, move.y, player)
          player.points = self.pointsForPlayer(player)      
        else
          raise "Der Zug ist nicht möglich, denn der Platz ist bereits besetzt oder nicht besetzbar."
        end
      else
        raise "Startkoordinaten sind nicht innerhalb des Spielfeldes."
      end
    end
  end
  
  # gets a player's points
  #
  # @param player [Player] the player, whos statistics will be returned
  # @return [Integer] the points of the player
  def playerStats(player)
    return self.playerStats(player.color)
  end
  
  # gets a player's points by the player's color
  #
  # @param playerColor [PlayerColor] the player's color, whos statistics will be returned
  # @return [Integer] the points of the player
  def playerStats(playerColor) 
    if playerColor == PlayerColor::RED
      return self.gameStats[0];
    else 
      return self.gameStats[1]
    end
  end
  
  # gets the players' statistics
  #
  # @return [Array<Integer>] the points for both players
  def gameStats
    stats = Array.new(2, Array.new(1))

    stats[0][0] = self.red.points
    stats[1][0] = self.blue.points
    
    return stats
  end
  
  # get the players' names
  #
  # @return [Array<String>] the names for both players
  def playerNames
    return [red.displayName, blue.displayName]
  end
  
  # sets the game-ended condition
  #
  # @param winner [Player] the winner of the game
  # @param reason [String] the winning reason
  def endGame(winner, reason)
    if condition.nil?
      @condition = Condition.new(winner, reason)
    end
  end
  
  # has the game ended?
  #
  # @return [Boolean] true, if the game has allready ended
  def gameEnded?
    return !self.condition.nil?
  end
  
  # gets the game's winner
  #
  # @return [Player] the game's winner
  def winner
    return condition.nil? ? nil : self.condition.winner
  end
  
  # gets the winning reason
  #
  # @return [String] the winning reason
  def winningReason
    return condition.nil? ? nil : self.condition.reason
  end
  
  # calculates a player's points
  #
  # @param player [Player] the player, whos point will be calculated
  # @return [Integer] the points of the player
  def pointsForPlayer(player)
    playerColor = player.color
    longestPath = 0

    outermostFieldsInCircuit = Array.new(Array.new)
    visited = Array.new(Constants::SIZE).map {|j| Array.new(Constants::SIZE).map {|i| false}} #// all by default initialized to false
    for x in 0..(Constants::SIZE-1)
      for y in 0..(Constants::SIZE-1)
        if visited[x][y] == false
          if self.board.fields[x][y].ownerColor == playerColor
            startOfCircuit = Array.new
            startOfCircuit.push(self.board.fields[x][y])
            circuit = self.circuit(startOfCircuit, Array.new)
            for f in circuit
              visited[f.x][f.y] = true
            end
            outermost = Array.new(2)
            if playerColor == PlayerColor::RED

              outermost[0] = self.bottomMostFieldInCircuit(circuit)
              outermost[1] = self.topMostFieldInCircuit(circuit)
            else
              outermost[0] = leftMostFieldInCircuit(circuit)
              outermost[1] = rightMostFieldInCircuit(circuit)
            end
            outermostFieldsInCircuit.push(outermost)

          end
          visited[x][y] = true
        end
      end
    end
    for fields in outermostFieldsInCircuit
      if (playerColor == PlayerColor::RED && fields[1].y - fields[0].y > longestPath)
        longestPath = fields[1].y - fields[0].y
      end
      if (playerColor == PlayerColor::BLUE && fields[1].x - fields[0].x > longestPath)
        longestPath = fields[1].x - fields[0].x
      end
    end
    
    return longestPath # return longestPath
  end

  # the following functions are helpers for the points calculation
  def bottomMostFieldInCircuit(circuit)
    bottomMostField = circuit[0]
    for f in circuit
      if f.y < bottomMostField.y
        bottomMostField = f
      end
    end
    return bottomMostField
  end

  def topMostFieldInCircuit(circuit)
    topMostField = circuit[0]
    for f in circuit
      if f.y > topMostField.y
        topMostField = f
      end
    end
    return topMostField
  end

  def leftMostFieldInCircuit(circuit)
    leftMostField = circuit[0]
    for f in circuit
      if f.x < leftMostField.x
        leftMostField = f
      end
    end
    return leftMostField
  end

  def rightMostFieldInCircuit(circuit)
    rightMostField = circuit[0]
    for f in circuit
      if f.x > rightMostField.x
        rightMostField = f
      end
    end
    return rightMostField
  end

  def circuit(circuit, visited)
    changed = false;
    toBeAddedFields = Array.new
    for f in circuit
      if !visited.include?(f)
        changed = true
        visited.push(f)
        for c in self.board.getConnections(f.x,f.y)
          if !circuit.include?(self.board.fields[c.x2][c.y2])
            toBeAddedFields.push(self.board.fields[c.x2][c.y2])
          end
          if !circuit.include?(self.board.fields[c.x1][c.y1])
            toBeAddedFields.push(self.board.fields[c.x1][c.y1])
          end
        end
      end
    end
    circuit.push(*toBeAddedFields)
    if changed
      return self.circuit(circuit, visited)
    else 
      return circuit
    end
  end
  
end
