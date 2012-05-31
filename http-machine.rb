require 'rubygems'
require 'eventmachine'
require 'em-http-request'

@bytes = 0
@io_read, @io_write = IO.pipe

EM.run do
  url = ''

  http = EM::HttpRequest.new(url).get
  http.stream { |chunk|
    if @bytes > 10000
      @io_write << "\n"
      EM.stop
    else
      @io_write << chunk
      puts chunk
      @bytes += chunk.length
    end
  }
  http.callback { EM.stop }
end

puts @io_read.gets
puts @bytes
