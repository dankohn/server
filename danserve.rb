class Server
  def run_server
    require 'socket'

    server = TCPServer.new 4000
    while session = server.accept
      request = session.gets
      reset_response request
      puts request
      session.print @response
      session.close
    end
  end

  def reset_response(request)
    @response = <<-END_OF_RESPONSE
    HTTP/1.1 200
    Content-Type: text/plaintext\r\n
    The time is: #{Time.now}
    request is: #{parse(request)}
    END_OF_RESPONSE
  end


  def parse(request)
    require 'uri'
    request_url = request.split(' ')[1]
    uri = URI(request_url)
    query = URI::decode_www_form(uri.query || '').to_h
    puts uri.path
    case uri.path
    when '/set'
      set query
    when '/get'
      get query
    end
  end

  def set(query)
    puts "set #{query}"
    query.each do |key, value|
      puts @db
      puts key
      puts value
      @db[key] = value
      puts "#{key} assigned #{value}"
    end
  end

  def initialize
    @db = Hash.new
    run_server
  end
end

Server.new