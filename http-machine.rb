require 'rubygems'
#require 'eventmachine'
gem 'eventmachine', "1.0.0.rc4"
require 'em-http-request'

@bytes = 0
@io_read, @io_write = IO.pipe

EM.run do
  #url = ''

  http = EM::HttpRequest.new(url, :connect_timeout => 5, :inactivity_timeout => 20).get
  http.stream { |chunk|
    if @bytes > 1500
      @io_write << "\n"
      EM.stop
    else
      #@io_write << chunk
      puts chunk
      @bytes += chunk.length
    end
  }
  http.callback { puts "callback"; EM.stop }
  http.errback { puts "error"; EM.stop}
end

puts @io_read.gets
puts @bytes
