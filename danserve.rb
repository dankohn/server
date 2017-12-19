class Server
  def run_server
    require 'socket'

    server = TCPServer.new 4000
    while session = server.accept
      reset_response
      parse session.gets
      session.print @response
      session.close
    end
  end

  def reset_response
    @response = <<~END_OF_RESPONSE
    HTTP/1.1 200
    Content-Type: text/plaintext\r\n
    time: #{Time.now}
    END_OF_RESPONSE
  end


  def parse(request)
    require 'uri'
    request_url = request.split(' ')[1]
    uri = URI(request_url)
    @response << "path: #{uri.path}\r\n"
    query = URI::decode_www_form(uri.query || '').to_h
    @response << "query: #{query}\r\n"
    case uri.path
    when '/set'
      set query
    when '/get'
      get query
    end
  end

  def set(query)
    query.each do |key, value|
      @response << "db: #{@db}\r\n"
      @db[key] = value
      @response << "#{key} => #{value}\r\n"
    end
    @response << "db: #{@db}\r\n"
  end

  def initialize
    @db = Hash.new
    run_server
  end
end

Server.new