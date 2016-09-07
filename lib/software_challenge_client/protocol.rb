# encoding: UTF-8
# frozen_string_literal: true
require 'socket'
require_relative 'board'
require_relative 'move'
require_relative 'player'
require_relative 'network'
require_relative 'client_interface'
require 'rexml/document'
require 'rexml/streamlistener'
require 'builder'

# This class handles communication to the server over the XML communication
# protocol. Messages from the server are parsed and moves are serialized and
# send back.
class Protocol
  include Logging
  include REXML::StreamListener

  # @!attribute [r] gamestate
  # @return [Gamestate] current gamestate
  attr_reader :gamestate
  # @!attribute [rw] roomId
  # @return [String] current room id
  attr_accessor :roomId
  # @!attribute [r] client
  # @return [ClientInterface] current client
  attr_reader :client

  def initialize(network, client)
    @gamestate = GameState.new
    @network = network
    @client = client
    @context = {} # for saving context when stream-parsing the XML
    @client.gamestate = @gamestate
  end

  # starts xml-string parsing
  #
  # @param text [String] the xml-string that will be parsed
  def process_string(text)
    logger.debug "Parse XML:\n#{text}\n----END XML"
    REXML::Document.parse_stream(text, self)
  end

  # called if an end-tag is read
  #
  # @param name [String] the end-tag name, that was read
  def tag_end(name)
    case name
    when 'board'
      logger.debug @gamestate.board.to_s
    when 'condition'
      logger.info 'Game ended'
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
    when 'room'
      @roomId = attrs['roomId']
      logger.info 'roomId : ' + @roomId
    when 'data'
      logger.debug "data(class) : #{attrs['class']}"
      if attrs['class'] == 'sc.framework.plugins.protocol.MoveRequest'
        @client.gamestate = gamestate
        move = @client.getMove
        sendString(move_to_xml(move))
      end
      if attrs['class'] == 'error'
        logger.info "Game ended - ERROR: #{attrs['message']}"
        @network.disconnect
      end
    when 'state'
      logger.debug 'new gamestate'
      @gamestate = GameState.new
      @gamestate.turn = attrs['turn'].to_i
      @gamestate.startPlayerColor = attrs['startPlayer'] == 'RED' ? PlayerColor::RED : PlayerColor::BLUE
      @gamestate.currentPlayerColor = attrs['currentPlayer'] == 'RED' ? PlayerColor::RED : PlayerColor::BLUE
      logger.debug "Turn: #{@gamestate.turn}"
    when 'red'
      logger.debug 'new red player'
      @gamestate.addPlayer(parsePlayer(PlayerColor::RED, attrs))
    when 'blue'
      logger.debug 'new blue player'
      @gamestate.addPlayer(parsePlayer(PlayerColor::BLUE, attrs))
    when 'board'
      logger.debug 'new board'
      @gamestate.board = Board.new
      @context[:current_tile_index] = nil
      @context[:current_tile_direction] = nil
    when 'tile'
      @context[:current_tile_index] = attrs['index'].to_i
      @context[:current_tile_direction] = attrs['direction'].to_i
    when 'field'
      type = FieldType.find_by_key(attrs['type'].to_sym)
      raise "unexpected field type: #{attrs['type']}. Known types are #{FieldType.map { |t| t.key.to_s }}" if type.nil?
      x = attrs['x'].to_i
      y = attrs['y'].to_i
      points = attrs['points'].to_i
      index = @context[:current_tile_index]
      direction = @context[:current_tile_direction]

      @gamestate.board.fields[[x, y]] = Field.new(type, x, y, index, direction, points)
    when 'lastMove'
      @gamestate.lastMove = Move.new
    when 'acceleration'
      @gamestate.lastMove.add_action_with_order(Acceleration.new(attrs['acc'].to_i), attrs['order'].to_i)
    when 'advance'
      @gamestate.lastMove.add_action_with_order(Advance.new(attrs['distance'].to_i), attrs['order'].to_i)
    when 'turn'
      @gamestate.lastMove.add_action_with_order(Turn.new(attrs['direction'].to_i), attrs['order'].to_i)
    when 'push'
      @gamestate.lastMove.add_action_with_order(Push.new(Direction.find_by_key(attrs['direction'].to_sym)), attrs['order'].to_i)
    when 'condition'
      @gamestate.condition = Condition.new(attrs['winner'], attrs['reason'])
    end
  end

  # Converts XML attributes for a Player to a new Player object
  #
  # @param expectedColor [PlayerColor] Color the player should have. Method will
  # throw an exception when expectedColor and color in attributes don't match.
  # @param attributes [Hash] Attributes for the new Player.
  # @return [Player] The created Player object.
  def parsePlayer(expectedColor, attributes)
    player = Player.new(
      PlayerColor.find_by_key(attributes['color'].to_sym),
      attributes['displayName']
    )
    if player.color != expectedColor
      throw new IllegalArgumentException("expected #{expectedColor} Player but got #{attributes['color']}")
    end
    player.points = attributes['points'].to_i
    player.direction = Direction.find_by_key(attributes['direction'].to_sym)
    player
  end

  # send a xml document
  #
  # @param document [REXML::Document] the document, that will be send to the connected server
  def sendXml(document)
    @network.sendXML(document)
  end

  # send a string
  #
  # @param document [String] The string that will be send to the connected server.
  def sendString(string)
    @network.sendString("<room roomId=\"#{@roomId}\">#{string}</room>")
  end

  # Converts a move to XML for sending to the server.
  #
  # @param move [Move] The move to convert to XML.
  def move_to_xml(move)
    builder = Builder::XmlMarkup.new(indent: 2)
    builder.data(class: 'move') do |data|
      data.actions do |actions|
        move.actions.each_with_index do |action, index|
          # Converting every action type here instead of requiring the Action
          # class interface to supply a method which returns the action hash
          # because XML-generation should be decoupled from internal data
          # structures.
          attribute = case action.type
                      when :acceleration
                        { acc: action.acceleration }
                      when :push, :turn
                        { direction: action.direction }
                      when :advance
                        { distance: action.distance }
                      when default
                        raise "unknown action type: #{action.type.inspect}. "\
                              "Can't convert to XML!"
                      end
          attribute[:order] = index
          actions.tag!(action.type, attribute)
        end
      end
    end
    move.hints.each do |hint|
      data.hint(content: hint.content)
    end
    builder.target!
  end

end
