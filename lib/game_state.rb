# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require_relative './util/constants'
require_relative 'player'
require_relative 'board'
require_relative 'move'
require_relative 'condition'
require_relative 'player_color'
require_relative 'field_type'

            require 'pry'

class GameState
  
  attr_accessor :turn
  attr_accessor :startPlayerColor
  attr_accessor :currentPlayerColor
  attr_accessor :red
  attr_accessor :blue
  attr_accessor :board
  attr_accessor :lastMove
  attr_accessor :condition
  
  def initialize
    self.currentPlayerColor = PlayerColor::RED
    self.startPlayerColor = PlayerColor::RED
    self.board = Board.new(true)
  end
  
  def addPlayer(player) 
    if player.color == PlayerColor::RED 
      @red = player
    else if player.color == PlayerColor::BLUE
        @blue = player
      end
    end
  end

def currentPlayer
    if self.currentPlayerColor == PlayerColor::RED
        self.red
        else
        self.blue
    end
end

  def otherPlayer
    if self.currentPlayerColor == PlayerColor::RED
      self.blue 
    else
      self.red
    end
  end
  
  def otherPlayerColor
    PlayerColor.opponent(self.currentPlayer)
  end
  
  def startPlayer
    if self.startPlayer == PlayerColor::RED 
      self.red
    else
      self.blue
    end
  end
  
  def switchCurrentPlayer
    if currentPlayer.color == PlayerColor::RED
      @currentPlayer = self.blue
    else
      @currentPlayer = self.red
    end
  end
  
  def prepareNextTurn(lastMove)
    @turn++
    @lastMove = lastMove;
    self.switchCurrentPlayer()
  end
  
  def round
    self.turn / 2
  end
  
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
    moves
  end
  
  def playerStats(player)
    #assert player != null;
    self.playerStats(player.color)
  end
  
  def playerStats(playerColor) 
    #assert playerColor != null;

    if playerColor == PlayerColor::RED
      self.gameStats[0];
    else 
      gameStats[1]
    end
  end
  
  def gameStats
    stats = Array.new(2, Array.new(1))

    stats[0][0] = self.red.points
    stats[1][0] = self.blue.points
    
    stats
  end
  
  def playerNames
    [red.displayName, blue.displayName]
  end
  
  def endGame(winner, reason)
    if condition.nil?
      @condition = Condition.new(winner, reason)
    end
  end
  
  def gameEnded
    !self.condition.nil?
  end
  
  def winner
    condition.nil? ? nil : self.condition.winner
  end
  
  def winningReason
    condition.nil? ? nil : self.condition.reason
  end
  
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


    longestPath # // return longestPath
  end

  def bottomMostFieldInCircuit(circuit)
    bottomMostField = circuit[0]
    for f in circuit
      if f.y < bottomMostField.y
        bottomMostField = f
      end
    end
    bottomMostField
  end

  def topMostFieldInCircuit(circuit)
    topMostField = circuit[0]
    for f in circuit
      if f.y > topMostField.y
        topMostField = f
      end
    end
    topMostField
  end

  def leftMostFieldInCircuit(circuit)
    leftMostField = circuit[0]
    for f in circuit
      if f.x < leftMostField.x
        leftMostField = f
      end
    end
    leftMostField
  end

  def rightMostFieldInCircuit(circuit)
    rightMostField = circuit[0]
    for f in circuit
      if f.x > rightMostField.x
        rightMostField = f
      end
    end
    rightMostField
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
      self.circuit(circuit, visited)
    else 
      circuit
    end
  end
  
end
