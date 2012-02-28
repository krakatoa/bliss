module Bliss
  class ParserMachine
    def initialize(path)
      #path = 'http://www.universobit.com.ar/AvisosUniversobit/trovit/AvisosUniversobit_1.xml'
      #path = 'http://www.aestrenar.com.ar/backend/rssAestrenar.xml'
      path = 'http://procarnet.es/feed/sumavisos/sumavisos.xml'
      @path = path
    end

    # def on_element('tag', block)

    def parse
      @io_read, @io_write = IO.pipe
      @bytes = 0

      EM.run do
        EM.defer do
          parser = Nokogiri::XML::SAX::Parser.new(Bliss::SaxParser.new)
          parser.parse_io(@io_read)
        end
      
        http = EM::HttpRequest.new(@path).get
        http.stream { |chunk|
          if @bytes > 20000
            @io_write << "\n"
            EM.stop
          else
            @io_write << chunk
            @bytes += chunk.length
          end
        }
        http.callback { EM.stop }
      end
      #puts @io_read.gets
      #puts @bytes
    end
  end
end

#require 'stringio'
#str = StringIO.new
#z = Zlib::GzipWriter.new(str)
#z.write(txt)
#z.close
