@bytes = 0
@io_read, @io_write = IO.pipe

EM.run do
  #url = 'http://www.universobit.com.ar/AvisosUniversobit/trovit/AvisosUniversobit_1.xml'
  #url = 'http://www.aestrenar.com.ar/backend/rssAestrenar.xml'
  url = 'http://procarnet.es/feed/sumavisos/sumavisos.xml'

  http = EM::HttpRequest.new(url).get
  http.stream { |chunk|
    if @bytes > 10000
      @io_write << "\n"
      EM.stop
    else
      @io_write << chunk
      @bytes += chunk.length
    end
  }
  http.callback { EM.stop }
end

puts @io_read.gets
puts @bytes
