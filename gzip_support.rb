require 'rubygems'
require 'eventmachine'
require 'em-http-request'

@bytes = 0
@io_read, @io_write = IO.pipe

require 'zlib'

f = File.new('test.xml', 'w')

EM.run do
  # jp
  #url = 'http://www.workgate.co.jp/feeds/sumavisos/sumavisos.xml'
  url = 'http://feeds.motoseller.com/feeds/?api_key=868b518ffa41be698cb02c189bbe52173d3d8aed&feed=usa-motosell-trovit'

  # gz
  #url = 'http://www.vivastreet.co.in/feed/download/generic_cars-cars_trucks-active.xml.gz' #"application/octet-stream"
  #url = 'http://www.autocosmos.com.ar/webservices/exchange/sumavisos.ar.xml.gz'# 'application/x-gzip'
  
  # zip
  # url = 'http://www.nexolocal.com.br/nl_xml/trovit/br/vehiculos.zip?user=sumavisos&pass=fsdgjfgsjdgf42354723' # 'application/zip'

  http = EM::HttpRequest.new(url, :inactivity_timeout => 1).get # :head => {'accept-encoding' => "gzip, deflate"}
  gzipped = false
  http.headers do
    puts http.response_header.inspect
    if (/^attachment.+filename.+\.gz/i === http.response_header['CONTENT_DISPOSITION']) or http.response_header.compressed? or ["application/octet-stream", "application/x-gzip"].include? http.response_header['CONTENT_TYPE']
      gzipped = true
    end
  end
  http.stream { |chunk|
    if @bytes > 15000
      #f.close
      EM.stop
    else
      if gzipped
        @zstream ||= Zlib::Inflate.new(Zlib::MAX_WBITS+16)
        chunk = @zstream.inflate(chunk)
      end
      puts chunk
      @io_write << chunk
    #f << chunk
      @bytes += chunk.length
    end
  }
end
if @zstream
  @zstream.close
end

puts @bytes
