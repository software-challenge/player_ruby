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
  include Logging
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
    logger.debug "Parse XML:\n#{text}\n----END XML"
    REXML::Document.parse_stream(text, self)
  end

  # called if an end-tag is read
  #
  # @param name [String] the end-tag name, that was read
  def tag_end(name)
    case name
    when "board"
      logger.debug @gamestate.board.to_s
    when "condition"
      logger.info "Game ended"
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
      logger.info "roomId : "+@roomID
    when "data"
      logger.debug "data(class) : "+attrs['class']
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
        logger.info "Game ended - ERROR: #{attrs['message']}"
        @network.disconnect
      end
    when "state"
      logger.debug 'new gamestate'
      @gamestate.turn = attrs['turn'].to_i
      @gamestate.startPlayerColor = attrs['startPlayer'] == 'RED' ? PlayerColor::RED : PlayerColor::BLUE
      @gamestate.currentPlayerColor = attrs['currentPlayer'] == 'RED' ? PlayerColor::RED : PlayerColor::BLUE
      logger.debug "Turn: #{@gamestate.turn}"
    when "red"
      logger.debug 'new red player'
      @gamestate.addPlayer(Player.new(attrs['color'] == 'RED' ? PlayerColor::RED : PlayerColor::BLUE))
      @gamestate.red.points = attrs['points'].to_i
    when "blue"
      logger.debug 'new blue player'
      @gamestate.addPlayer(Player.new(attrs['color'] == 'RED' ? PlayerColor::RED : PlayerColor::BLUE))
      @gamestate.blue.points = attrs['points'].to_i
    when "board"
      logger.debug 'new board'
      @gamestate.board = Board.new
    when "field"
      type = FieldType.find_by_key(attrs['type'].to_sym)
      raise "unexpected field type: #{attrs['type']}. Known types are #{FieldType.map{ |t| t.key.to_s }}" if type.nil?
      x = attrs['x'].to_i
      y = attrs['y'].to_i

      @gamestate.board.fields[[x,y]] = Field.new(type, x, y)
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
