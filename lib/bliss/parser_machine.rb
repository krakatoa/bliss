module Bliss
  class ParserMachine
    def initialize(path)
      @path = path
      
      @sax_parser = Bliss::SaxParser.new

      @parser = Nokogiri::XML::SAX::PushParser.new(@sax_parser)

      @file = File.new('output.xml', 'w')

      @root = nil
      @nodes = nil

      on_root {}
    end

    def on_root(&block)
      return false if not block.is_a? Proc
      @sax_parser.on_root { |root|
        @root = root
        block.call(root)
      }
    end

    def on_tag_close(element, &block)
      @sax_parser.on_tag_close(element, block)
    end

    def root
      @root
    end

    def close
      @sax_parser.close
    end

    def parse
      @bytes = 0

      EM.run do
        http = EM::HttpRequest.new(@path).get
        http.stream { |chunk|
          @parser << chunk

          @bytes += chunk.length
          
          if not @sax_parser.is_closed?
            @file << chunk
          else
            last_index = chunk.index('</ad>') + 4
            @file << chunk[0..last_index]
            @file << "</#{self.root}>"

            EM.stop
          end
        }
        http.callback { EM.stop }
      end
    end
  end
end

#require 'stringio'
#str = StringIO.new
#z = Zlib::GzipWriter.new(str)
#z.write(txt)
#z.close
