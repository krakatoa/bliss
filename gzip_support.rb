require 'rubygems'
require 'eventmachine'
require 'em-http-request'

@bytes = 0
@io_read, @io_write = IO.pipe

require 'zlib'

f = File.new('test.xml', 'w')

EM.run do
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
