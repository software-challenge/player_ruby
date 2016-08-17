# encoding: UTF-8
require 'socket'
require_relative 'board'
require_relative 'move'
require_relative 'player'
require_relative 'network'
require_relative 'client_interface'
require 'rexml/document'
require 'rexml/streamlistener'

# This class handles the parsing of xml strings according to the network protocol of twixt
class Protocol
  include REXML::StreamListener

  # @!attribute [r] gamestate
  # @return [Gamestate] current gamestate
  attr_reader :gamestate
  # @!attribute [rw] roomID
  # @return [String] current room id
  attr_accessor :roomID
  # @!attribute [r] client
  # @return [ClientInterface] current client
  attr_reader :client
  @network

  def initialize(network, client)
    @gamestate = GameState.new
    @network, @client = network, client
    self.client.gamestate = self.gamestate
  end

  # starts xml-string parsing
  #
  # @param text [String] the xml-string that will be parsed
  def processString(text)
    list = self
    #puts "Parse XML:\n#{text}\n----END XML"
    REXML::Document.parse_stream(text, list)
  end

  # called if an end-tag is read
  #
  # @param name [String] the end-tag name, that was read
  def tag_end(name)
    case name
    when "board"
      puts @gamestate.board.to_s
    when "condition"
      puts "Game ended"
      @network.disconnect
    end
  end

  # called if a start tag is read
  # Depending on the tag the gamestate is updated
  # or the client will be asked for a move
  #
  # @param name [String] the start-tag, that was read
  # @param attrs [Dictionary<String, String>] Attributes attached to the tag
  def tag_start(name, attrs)
    case name
    when "room"
      @roomID = attrs['roomId']
      puts "roomId : "+@roomID
    when "data"
      puts "data(class) : "+attrs['class']
      if attrs['class'] == "sc.framework.plugins.protocol.MoveRequest"
        @client.gamestate = self.gamestate
        move = @client.getMove
        document = REXML::Document.new
        document.add_element('room',{'roomId' => @roomID})
        data = REXML::Element.new('data')
        data.add_attribute('class', 'move')
        data.add_attribute('x', move.x)
        data.add_attribute('y', move.y)
        document.root.add_element(data)
        for h in move.hints
          hint = REXML::Element.new('hint')
          hint.add_attribute('content', h.content)
          document.root.elements['data'].elements << hint
        end
        self.sendXml(document)
      end
      if attrs['class'] == "error"
        puts "Game ended - ERROR"
        puts attrs['message']
        @network.disconnect
      end
    when "state"
      puts 'new gamestate'
      @gamestate.turn = attrs['turn'].to_i
      @gamestate.startPlayerColor = attrs['startPlayer'] == 'RED' ? PlayerColor::RED : PlayerColor::BLUE
      @gamestate.currentPlayerColor = attrs['currentPlayer'] == 'RED' ? PlayerColor::RED : PlayerColor::BLUE
      puts "Turn: #{@gamestate.turn}"
    when "red"
      puts 'new red player'
      @gamestate.addPlayer(Player.new(attrs['color'] == 'RED' ? PlayerColor::RED : PlayerColor::BLUE))
      @gamestate.red.points = attrs['points'].to_i
    when "blue"
      puts 'new blue player'
      @gamestate.addPlayer(Player.new(attrs['color'] == 'RED' ? PlayerColor::RED : PlayerColor::BLUE))
      @gamestate.blue.points = attrs['points'].to_i
    when "board"
      puts 'new board'
      @gamestate.board = Board.new(true)
    when "field"
      type = FieldType::NORMAL
      ownerColor = PlayerColor::NONE
      case attrs['type']
      when 'SWAMP'
        type = FieldType::SWAMP
      when 'RED'
        type = FieldType::RED
      when 'BLUE'
        type = FieldType::BLUE
      when "winner"
        puts "Game ended"
        @network.disconnect
      end

      case attrs['owner']
      when 'RED'
        ownerColor = PlayerColor::RED
      when 'BLUE'
        ownerColor = PlayerColor::BLUE
      end
      x = attrs['x'].to_i
      y = attrs['y'].to_i

      @gamestate.board.fields[x][y] = Field.new(type, x, y)
      @gamestate.board.fields[x][y].ownerColor = ownerColor
    when "connection"
      @gamestate.board.connections.push(Connection.new(attrs['x1'].to_i, attrs['y1'].to_i, attrs['x2'].to_i, attrs['y2'].to_i, attrs['owner']))
    when "lastMove"
      @gamestate.lastMove = Move.new(attrs['x'], attrs['y'])
    when "condition"
      @gamestate.condition = Condition.new(attrs['winner'], attrs['reason'])
    end
  end

  # send a xml document
  #
  # @param document [REXML::Document] the document, that will be send to the connected server
  def sendXml(document)
    @network.sendXML(document)
  end

end
