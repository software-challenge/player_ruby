#game board
require_relative './util/constants'
require_relative 'game_state'
require_relative 'player'
require_relative 'field_type'
require_relative 'field'

require 'securerandom'

# @author Ralf-Tobias Diekert
# A representation of a twixt game board
class Board
  # @!attribute [r] fields
  # @return [Array<Array<Field>>] the board's fields
  attr_reader :fields
  # @!attribute [r] connections
  # @return [Array<Connection>] the board's connections
  attr_reader :connections
  
  def initialize
    self.init
  end
  
  # Initializes the board
  #
  # @param init [Boolean] if 'true', then the board will be initialized with swamps, otherwise the board will be completely empty
  def initialize(init)
    if init
      self.init
    else
      self.makeClearBoard
    end
  end
  
  # Initializes the board with swamps
  def init 
    @fields = Array.new(Constants::SIZE) {Array.new(Constants::SIZE)}
    @fields[0][0] = Field.new(FieldType::SWAMP, 0, 0)
    @fields[0][Constants::SIZE - 1] = Field.new(FieldType::SWAMP, 0, Constants::SIZE - 1)
    @fields[Constants::SIZE - 1][0] = Field.new(FieldType::SWAMP, Constants::SIZE - 1, 0)
    @fields[Constants::SIZE - 1][Constants::SIZE - 1] = Field.new(FieldType::SWAMP, Constants::SIZE - 1, Constants::SIZE - 1)
    for x in 1..(Constants::SIZE - 2)
      @fields[x][0] = Field.new(FieldType::RED, x, 0);
      @fields[x][Constants::SIZE - 1] = Field.new(FieldType::RED, x, Constants::SIZE - 1);
    end
    for y in 1..(Constants::SIZE - 2)
      @fields[0][y] = Field.new(FieldType::BLUE, 0, y);
      @fields[Constants::SIZE - 1][y] = Field.new(FieldType::BLUE, Constants::SIZE - 1, y);
    end
    for x in 1..(Constants::SIZE - 2)
      for y in 1..(Constants::SIZE - 2) 
        @fields[x][y] = Field.new(FieldType::NORMAL, x, y);
      end
    end
    self.placeSwamps()
    @connections = Array.new;
  end
  
  # Places swamps at random coordinates
  def placeSwamps
    # big swamp
    x = 1 + SecureRandom.random_number(Constants::SIZE - 4)
    y = 1 + SecureRandom.random_number(Constants::SIZE - 4)
    for i in x..(x + 2)
      for j in y..(y + 2)
        self.fields[i][j].type = FieldType::SWAMP
      end
    end
    # first medium swamp
    x = 1 + SecureRandom.random_number(Constants::SIZE - 3)
    y = 1 + SecureRandom.random_number(Constants::SIZE - 3)
    for i in x..(x + 1)
      for j in y..(y + 1)
        self.fields[i][j].type = FieldType::SWAMP
      end
    end
    # second medium swamp
    x = 1 + SecureRandom.random_number(Constants::SIZE - 3)
    y = 1 + SecureRandom.random_number(Constants::SIZE - 3)
    for i in x..(x + 1)
      for j in y..(y + 1)
        self.fields[i][j].type = FieldType::SWAMP
      end
    end
    # little swamp
    x = 1 + SecureRandom.random_number(Constants::SIZE - 2)
    y = 1 + SecureRandom.random_number(Constants::SIZE - 2)
    self.fields[x][y].type = FieldType::SWAMP
  end

  
  # creates a cleared board  
  def makeClearBoard
    @fields = Array.new(Constants::SIZE, Array.new(Constants::SIZE))
    @connections = Array.new
  end
  
  # gets the owner's color for the field at the coordinate (x, y)
  # 
  # @param x [Integer] x-coordinate
  # @param y [Integer] y-coordinate
  # @return [PlayerColor] owner's color of field (x, y)
  def getOwnerColor(x, y) 
    return self.fields[x][y].ownerColor
  end
  
  
  # sets the owner's color for the field at the coordinate (x, y)
  # 
  # @param x [Integer] x-coordinate
  # @param y [Integer] y-coordinate
  # @param player [Player] new owner of field (x, y)
  def put(x, y, player)
    self.fields[x][y].owner = player.color;
    self.createNewWires(x, y);
  end

  # creates wires at the coordinate (x, y), if it is possible
  # 
  # @param x [Integer] x-coordinate
  # @param y [Integer] y-coordinate
  def createNewWires(x, y)
    if self.checkPossibleWire(x, y, x - 2, y - 1)
      self.createWire(x, y, x - 2, y - 1)
    end
    if self.checkPossibleWire(x, y, x - 1, y - 2)
      self.createWire(x, y, x - 1, y - 2)
    end
    if self.checkPossibleWire(x, y, x - 2, y + 1)
      self.createWire(x, y, x - 2, y + 1)
    end
    if self.checkPossibleWire(x, y, x - 1, y + 2)
      self.createWire(x, y, x - 1, y + 2)
    end
    if self.checkPossibleWire(x, y, x + 2, y - 1)
      self.createWire(x, y, x + 2, y - 1)
    end
    if self.checkPossibleWire(x, y, x + 1, y - 2)
      self.createWire(x, y, x + 1, y - 2)
    end
    if self.checkPossibleWire(x, y, x + 2, y + 1)
      self.createWire(x, y, x + 2, y + 1)
    end
    if self.checkPossibleWire(x, y, x + 1, y + 2)
      self.createWire(x, y, x + 1, y + 2)
    end
    
  end 

  # creates a new wire
  # 
  # @param x1 [Integer] x-coordinate starting point
  # @param y1 [Integer] y-coordinate starting point
  # @param x2 [Integer] x-coordinate ending point
  # @param y2 [Integer] y-coordinate ending point
  def createWire(x1, y1, x2, y2)
    self.connections.push(Connection.new(x1, y1, x2, y2, self.fields[x1][y1].ownerColor))
  end

  # checks, if a wire can be placed at specified coordinates
  # 
  # @param x1 [Integer] x-coordinate starting point
  # @param y1 [Integer] y-coordinate starting point
  # @param x2 [Integer] x-coordinate ending point
  # @param y2 [Integer] y-coordinate ending point
  # @return [Boolean] 'true', if a wire can be placed at specified coordinates
  def checkPossibleWire(x1, y1, x2, y2)
    if x2 < Constants::SIZE && y2 < Constants::SIZE && x2 >= 0 && y2 >= 0
      if self.fields[x2][y2].ownerColor == self.fields[x1][y1].ownerColor
        return !self.existsBlockingWire(x1, y1, x2, y2)
      end
    end
    return false
  end

  # checks, if a blocking wire exists
  # 
  # @param x1 [Integer] x-coordinate starting point
  # @param y1 [Integer] y-coordinate starting point
  # @param x2 [Integer] x-coordinate ending point
  # @param y2 [Integer] y-coordinate ending point
  # @return [Boolean] 'true', if another wire would block the creation of a new wire at specified coordinates
  def existsBlockingWire(x1, y1, x2, y2)
    smallerX, biggerX = [x1, x2].minmax
    smallerY, biggerY = [y1, y2].minmax
    for x in smallerX..biggerX
      for y in smallerY..biggerY # checks all 6 Fields, from
        # where there could be
        # blocking connections
        if !self.fields[x][y].ownerColor.nil? && (x != x1 || y != y1) && 
            (x != x2 || y != y2) # excludes the Fields with no owner and
          # the fields (x1, y2), (x2, y2)
          # themselves.
          if self.isWireBlocked(x1, y1, x2, y2, x, y)
            return true
          end
        end
      end
    end
    return false
  end
  
  # gets connections for the coordinate (x, y)
  # 
  # @param x [Integer] x-coordinate
  # @param y [Integer] y-coordinate
  # @return [Array] Array of connections from field (x, y)
  def getConnections(x, y)
    xyConnections = Array.new
    if !self.connections.nil?
      for c in self.connections
        if c.x1 == x && c.y1 == y 
          xyConnections.push(Connection.new(x, y, c.x2, c.y2, c.ownerColor))
        end
        if c.x2 == x && c.y2 == y
          xyConnections.push(Connection.new(x, y, c.x1, c.y1, c.ownerColor))
        end
      end
    end
    return xyConnections
  end

  # following functions are helper functions for the blocking wire check
  #http://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
  def onSegment(px,py,qx,qy,rx,ry)
    if qx <= [px, rx].max && qx >= [px, rx].min &&
        qy <= [py, ry].max && qy >= [py, ry].min
      return true
    end
    return false
  end
 
  def orientation(px,py,qx,qy,rx,ry)
    val = (qy - py) * (rx - qx) -
      (qx - px) * (ry - qy)
 
    if val == 0
      return 0
    end
    if val > 0
      return 1
    end
    return 2
  end
 
  def doIntersect(p1x,p1y, q1x,q1y, p2x,p2y, q2x,q2y)
    o1 = orientation(p1x,p1y, q1x,q1y, p2x,p2y)
    o2 = orientation(p1x,p1y, q1x,q1y, q2x,q2y)
    o3 = orientation(p2x,p2y, q2x,q2y, p1x,p1y)
    o4 = orientation(p2x,p2y, q2x,q2y, q1x,q1y)
 
    if o1 != o2 && o3 != o4
      return true
    end
 
    if o1 == 0 && onSegment(p1x,p1y, p2x,p2y, q1x,q1y)
      return true
    end
 
    if o2 == 0 && onSegment(p1x,p1y, q2x,q2y, q1x,q1y)
      return true
    end
 
    if o3 == 0 && onSegment(p2x,p2x, p1x,p1y, q2x,q2y)
      return true
    end
     
    if o4 == 0 && onSegment(p2x,p2y, q1x,q1y, q2x,q2y)
      return true
    end
 
    return false
  end

  # checks for the wire (x1, y1) -> (x2, y2), if it is blocked by any connection going out from (x,y).
  # 
  # @param x1 [Integer] x-coordinate starting point
  # @param y1 [Integer] y-coordinate starting point
  # @param x2 [Integer] x-coordinate ending point
  # @param y2 [Integer] y-coordinate ending point
  # @param x [Integer] x-coordinate comparison field
  # @param y [Integer] y-coordinate comparison field 
  # @return [Boolean]  'true', if another wire would block the creation of a new wire at specified coordinates
  def isWireBlocked(x1, y1, x2, y2, x, y)
    for c in getConnections(x, y)
      if self.doIntersect(x1, y1, x2, y2, x, y, c.x2, c.y2)
        return true
      end
    end
    return false
  end

  def to_s
    return self.fields.map { |f| f.map {|i| (i.ownerColor==PlayerColor::RED ? 'R' : (i.ownerColor==PlayerColor::BLUE ? 'B' : (i.type==FieldType::SWAMP ? 'S' : (i.type==FieldType::RED ? 'r' : (i.type==FieldType::BLUE ? 'b' : ' '))))) }.join(",")}.join("\n")
  end
  
  def ==(another_board)
    for x in 0..(Constants.SIZE - 1)
      for y in 0..(Constants.SIZE - 1)
        if self.fields[x][y] != another_board.fields[x][y]
          return false;
        end
      end
    end
    if self.connections.length != another_board.connections.length
      return false;
    end
    for c in another_board.connections
      if self.connections.include?(c)
        return false
      end
    end
    
    return true;
  end
end
