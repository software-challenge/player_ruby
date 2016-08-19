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
  # @!attribute [rw] roomID
  # @return [String] current room id
  attr_accessor :roomID
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
      @roomID = attrs['roomId']
      logger.info "roomId : "+@roomID
    when 'data'
      logger.debug "data(class) : #{attrs['class']}"
      if attrs['class'] == "sc.framework.plugins.protocol.MoveRequest"
        @client.gamestate = self.gamestate
        move = @client.getMove
        self.sendXml(move_to_xml(move))
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
      @context[:current_tile_index] = nil
      @context[:current_tile_direction] = nil
    when "tile"
      @context[:current_tile_index] = attrs['index'].to_i
      @context[:current_tile_direction] = attrs['direction'].to_i
    when "field"
      type = FieldType.find_by_key(attrs['type'].to_sym)
      raise "unexpected field type: #{attrs['type']}. Known types are #{FieldType.map{ |t| t.key.to_s }}" if type.nil?
      x = attrs['x'].to_i
      y = attrs['y'].to_i
      index = @context[:current_tile_index]
      direction = @context[:current_tile_direction]

      @gamestate.board.fields[[x,y]] = Field.new(type, x, y, index, direction)
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

  # Converts a player to XML for sending to the server.
  #
  # @param move [Move] The player move to convert to XML.
  def move_to_xml(move)
    builder = Builder::XmlMarkup.new(indent: 2)
    builder.data(class: 'move') do |data|
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
                    when :step
                      { distance: action.distance }
                    when default
                      raise "unknown action type: #{action.type.inspect}. "\
                            "Can't convert to XML!"
                    end
        attribute[:order] = index
        data.tag!(action.type, attribute)
      end
      move.hints.each do |hint|
        data.hint(content: hint.content)
      end
    end
    builder.target!
  end
end
