# frozen_string_literal: true

class Server
  def get(query)
    @response << "db: #{@db}\r\n"
    query.each do |key, value|
      next unless key == 'key'
      if (lookup = @db[value])
        respond "successful lookup: #{value} => #{lookup}"
      else respond "failed lookup: no entry for #{value}"
      end
    end
  end

  def initialize
    @db = {}
    run_server
  end

  # rubocop:disable Metrics/MethodLength
  def parse(request)
    require 'uri'
    request_url = request.split(' ')[1]
    uri = URI(request_url)
    respond "path: #{uri.path}"
    query = URI.decode_www_form(uri.query || '').to_h
    respond "query: #{query}"
    case uri.path
    when '/set'
      set query
    when '/get'
      get query
    end
  end
  # rubocop:enable Metrics/MethodLength

  def reset_response
    @response = <<~TOP_OF_RESPONSE
      HTTP/1.1 200
      Content-Type: text/plaintext\r\n
      time: #{Time.now}
      TOP_OF_RESPONSE
  end

  def respond(string)
    @response << "#{string}\r\n"
  end

  def run_server
    require 'socket'
    server = TCPServer.new 4000
    while (session = server.accept)
      reset_response
      parse session.gets
      session.print @response
      session.close
    end
  end

  def set(query)
    respond "db: #{@db}"
    query.each do |key, value|
      @db[key] = value
      respond "assigned: #{key} => #{value}"
    end
    respond "db: #{@db}"
  end
end

Server.new
