# encoding: UTF-8
require 'software_challenge_client'
require 'optparse'
require 'ostruct'

require_relative 'client'

options = OpenStruct.new
options.host = '127.0.0.1'
options.port = 13050
options.reservation = ''

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: main.rb [OPTIONS]"
  opt.separator  ""
  opt.separator  "Options"

  opt.on("-p","--port PORT", Integer,"connect to the server at PORT (default #{options.port})") do |p|
    options.port = p
  end

  opt.on("-h","--host HOST","the host's IP address (default #{options.host})") do |h|
    options.host = h
  end

  opt.on_tail("-?", "--help", "Show this message") do
    puts opt
    exit
  end

end

opt_parser.parse!(ARGV)

client = Client.new
runner = Runner.new(options.host, options.port, client)
runner.start()
