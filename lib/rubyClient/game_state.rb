require_relative './util/constants'
require_relative 'player'
require_relative 'board'
require_relative 'move'
require_relative 'condition'
require_relative 'player_color'
require_relative 'field_type'

class GameState
  
  attr_accessor :turn
  attr_accessor :startPlayerColor
  attr_accessor :currentPlayerColor
  attr_reader :red
  attr_reader :blue
  attr_accessor :board
  attr_accessor :lastMove
  attr_accessor :condition
  
  def initialize
    self.currentPlayerColor = PlayerColor::RED
    self.startPlayerColor = PlayerColor::RED
    self.board = Board.new(true)
  end
  
  # adds a player to the gamestate
  def addPlayer(player) 
    if player.color == PlayerColor::RED 
      @red = player
    else if player.color == PlayerColor::BLUE
        @blue = player
      end
    end
  end

  # gets the current player
  def currentPlayer
    if self.currentPlayerColor == PlayerColor::RED
      return self.red
    else
      return self.blue
    end
  end

  # gets the other (not the current) player
  def otherPlayer
    if self.currentPlayerColor == PlayerColor::RED
      return self.blue 
    else
      return self.red
    end
  end
  
  # gets the other (not the current) player's color
  def otherPlayerColor
    return PlayerColor.opponent(self.currentPlayerColor)
  end
  
  # gets the start player
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
  
  # prepares next turn
  def prepareNextTurn(lastMove)
    @turn++
    @lastMove = lastMove;
    self.switchCurrentPlayer()
  end
  
  # gets current round
  def round
    return self.turn / 2
  end
  
  # gets possible moves
  def getPossibleMoves
    enemyFieldType = currentPlayer.color == PlayerColor::RED ? FieldType::BLUE : FieldType::RED
    moves = Array.new
    for x in 0..(Constants::SIZE-1)
      for y in 0..(Constants::SIZE-1)
        if (self.board.fields[x][y].owner == PlayerColor::NONE &&
              self.board.fields[x][y].type != FieldType::SWAMP &&
              self.board.fields[x][y].type != enemyFieldType)
          moves.push(Move.new(x, y))
        end
      end
    end
    return moves
  end
  
  # performs a move on the gamestate
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
  
  # gets a player's statistics
  def playerStats(player)
    return self.playerStats(player.color)
  end
  
  # gets a player's statistics, if the player's color is provided
  def playerStats(playerColor) 
    if playerColor == PlayerColor::RED
      return self.gameStats[0];
    else 
      return self.gameStats[1]
    end
  end
  
  # gets the players' statistics
  def gameStats
    stats = Array.new(2, Array.new(1))

    stats[0][0] = self.red.points
    stats[1][0] = self.blue.points
    
    return stats
  end
  
  # get the players' names
  def playerNames
    return [red.displayName, blue.displayName]
  end
  
  # sets the game-ended condition
  def endGame(winner, reason)
    if condition.nil?
      @condition = Condition.new(winner, reason)
    end
  end
  
  # has the game ended?
  def gameEnded?
    return !self.condition.nil?
  end
  
  # gets the game's winner
  def winner
    return condition.nil? ? nil : self.condition.winner
  end
  
  # gets the winning reason
  def winningReason
    return condition.nil? ? nil : self.condition.reason
  end
  
  # calculates a player's points
  def pointsForPlayer(player)
    playerColor = player.color
    longestPath = 0

    outermostFieldsInCircuit = Array.new(Array.new)
    visited = Array.new(Constants::SIZE).map {|j| Array.new(Constants::SIZE).map {|i| false}} #// all by default initialized to false
    for x in 0..(Constants::SIZE-1)
      for y in 0..(Constants::SIZE-1)
        if visited[x][y] == false
          if self.board.fields[x][y].owner == playerColor
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
