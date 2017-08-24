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


  # called when text is encountered
  def text(text)
    @context[:last_text] = text
  end

  # called if an end-tag is read
  #
  # @param name [String] the end-tag name, that was read
  def tag_end(name)
    case name
    when 'board'
      logger.debug @gamestate.board.to_s
    when 'type'
      @context[:player].cards << CardType.find_by_key(@context[:last_text].to_sym)
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
      @context[:data_class] = attrs['class']
      if attrs['class'] == 'sc.framework.plugins.protocol.MoveRequest'
        @client.gamestate = gamestate
        move = @client.move_requested
        sendString(move_to_xml(move))
      end
      if attrs['class'] == 'error'
        logger.info "Game ended - ERROR: #{attrs['message']}"
        @network.disconnect
      end
      if attrs['class'] == 'result'
        logger.info 'Got game result'
        @network.disconnect
      end
    when 'state'
      logger.debug 'new gamestate'
      @gamestate = GameState.new
      @gamestate.turn = attrs['turn'].to_i
      @gamestate.start_player_color = attrs['startPlayer'] == 'RED' ? PlayerColor::RED : PlayerColor::BLUE
      @gamestate.current_player_color = attrs['currentPlayer'] == 'RED' ? PlayerColor::RED : PlayerColor::BLUE
      logger.debug "Turn: #{@gamestate.turn}"
    when 'red'
      logger.debug 'new red player'
      player = parsePlayer(attrs)
      if player.color != PlayerColor::RED
        throw new IllegalArgumentException("expected #{PlayerColor::RED} Player but got #{player.color}")
      end
      @gamestate.add_player(player)
      @context[:player] = player
    when 'blue'
      logger.debug 'new blue player'
      player = parsePlayer(attrs)
      if player.color != PlayerColor::BLUE
        throw new IllegalArgumentException("expected #{PlayerColor::BLUE} Player but got #{player.color}")
      end
      @gamestate.add_player(player)
      @context[:player] = player
    when 'board'
      logger.debug 'new board'
      @gamestate.board = Board.new
      @context[:current_tile_index] = nil
      @context[:current_tile_direction] = nil
    when 'fields'
      type = FieldType.find_by_key(attrs['type'].to_sym)
      index = attrs['index'].to_i
      raise "unexpected field type: #{attrs['type']}. Known types are #{FieldType.map { |t| t.key.to_s }}" if type.nil?
      @gamestate.board.fields[index] = Field.new(type, index)
    when 'lastMove'
      @gamestate.last_move = Move.new
    when 'advance'
      @gamestate.last_move.add_action_with_order(
          Advance.new(attrs['distance'].to_i), attrs['order'].to_i
      )
    when 'card'
      @gamestate.last_move.add_action_with_order(
          Card.new(CardType.find_by_key(attrs['type'].to_sym), attrs['value'].to_i),
          attrs['order'].to_i
      )
    when 'skip'
      @gamestate.last_move.add_action_with_order(
          Skip.new, attrs['order'].to_i
      )
    when 'eatSalad'
      @gamestate.last_move.add_action_with_order(
          EatSalad.new, attrs['order'].to_i
      )
    when 'fallBack'
      @gamestate.last_move.add_action_with_order(
          FallBack.new, attrs['order'].to_i
      )
    when 'exchangeCarrots'
      @gamestate.last_move.add_action_with_order(
          ExchangeCarrots.new(attrs['value'].to_i), attrs['order'].to_i
      )
    when 'winner'
      winning_player = parsePlayer(attrs)
      @gamestate.condition = Condition.new(winning_player)
      @context[:player] = winning_player
    when 'left'
      logger.debug 'got left event, terminating'
      @network.disconnect
    when 'lastNonSkipAction'
      @context[:player].last_non_skip_action =
        case attrs['class']
        when 'advance'
          Advance.new(attrs['distance'].to_i)
        when 'card'
          Card.new(CardType.find_by_key(attrs['type'].to_sym), attrs['value'].to_i)
        when 'skip'
          Skip.new
        when 'eatSalad'
          EatSalad.new
        when 'fallBack'
          FallBack.new
        when 'exchangeCarrots'
          ExchangeCarrots.new(attrs['value'].to_i)
        else
          raise "Unknown action type #{attrs['class']}"
        end
    end
  end

  # Converts XML attributes for a Player to a new Player object
  #
  # @param attributes [Hash] Attributes for the new Player.
  # @return [Player] The created Player object.
  def parsePlayer(attributes)
    player = Player.new(
      PlayerColor.find_by_key(attributes['color'].to_sym),
      attributes['displayName']
    )
    player.points = attributes['points'].to_i
    player.index = attributes['index'].to_i
    player.carrots = attributes['carrots'].to_i
    player.salads = attributes['salads'].to_i
    player.cards = []
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

  # converts "this_snake_case" to "thisSnakeCase"
  def snake_case_to_lower_camel_case(string)
    string.split('_').inject([]) do |result, e|
      result + [result.empty? ? e : e.capitalize]
    end.join
  end

  # Converts a move to XML for sending to the server.
  #
  # @param move [Move] The move to convert to XML.
  def move_to_xml(move)
    builder = Builder::XmlMarkup.new(indent: 2)
    builder.data(class: 'move') do |data|
      move.actions.each_with_index do |action, index|
        # Converting every action type here instead of requiring the Action
        # class interface to supply a method which returns the action hash
        # because XML-generation should be decoupled from internal data
        # structures.
        attribute = case action.type
                    when :advance
                      { distance: action.distance }
                    when :skip, :eat_salad, :fall_back
                      {}
                    when :card
                      { type: action.card_type.key.to_s, value: action.value }
                    when :exchange_carrots
                      { value: action.value }
                    else
                      raise "unknown action type: #{action.type.inspect}. "\
                            "Can't convert to XML!"
                    end
        attribute[:order] = index
        data.tag!(snake_case_to_lower_camel_case(action.type.to_s), attribute)
      end
    end
    move.hints.each do |hint|
      data.hint(content: hint.content)
    end
    builder.target!
  end

end
