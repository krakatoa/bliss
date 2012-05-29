require 'rubygems'
require 'eventmachine'
require 'em-http-request'

@bytes = 0
@io_read, @io_write = IO.pipe

require 'rubygems/package'
require 'stringio'
@str = StringIO.new

f = File.new('test.xml', 'w')
@buf = ''
@tar_reader = Zlib::GzipReader.new(f)

EM.run do
  #url = 'http://www.universobit.com.ar/AvisosUniversobit/trovit/AvisosUniversobit_1.xml'
  #url = 'http://www.aestrenar.com.ar/backend/rssAestrenar.xml'
  #url = 'http://procarnet.es/feed/sumavisos/sumavisos.xml'
  #url = 'http://soloduenos.com/sumavisos/xml.asp'
  #url = 'http://taakidom.pl/import/trovit/trovit.xml'
  #url = 'http://www.experteer.de/export/deu/adsdeck.xml'
  #url = 'http://case.bricabrac.it/trovit_case.xml' # 'application/xml'
  #url = 'http://www.deautos.com/sumavisos/feed.xml'

  # gz
  url = 'http://www.vivastreet.co.in/feed/download/generic_cars-cars_trucks-active.xml.gz' #"application/octet-stream"
  url = 'http://www.workgate.co.jp/feeds/sumavisos/sumavisos.xml'

  url = 'http://www.espacioinmobiliario.mx/feeds/feed.xml' # timeout
  url = 'http://www.globaliza.com/exportaciones/sumavisos/sumavisos.xml' # dice que falta Type

  http = EM::HttpRequest.new(url, :inactivity_timeout => 10).get #:head => {'accept-encoding' => "gzip, deflate"}
  gzipped = false
  http.headers do
    puts http.response_header.inspect
    if http.response_header['CONTENT_TYPE'] == "application/octet-stream"
      gzipped = true
    end
  end
  http.stream { |chunk|
    if @bytes > 15000
      f.close
      EM.stop
    else
      #@str << chunk
      #@buf << chunk
      @tar_reader << chunk
      #f << chunk
      @bytes += chunk.length
    end
  }
  #http.errback { puts 'no data!' }
  #http.callback { EM.stop }
end

#puts @io_read.gets
puts @buf
puts @bytes
