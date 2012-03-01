module Bliss
  class ParserMachine
    def initialize(path, filepath=nil)
      @path = path
      
      @sax_parser = Bliss::SaxParser.new

      @parser = Nokogiri::XML::SAX::PushParser.new(@sax_parser)

      if filepath
        @file = File.new(filepath, 'w')
      end

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

    def on_tag_open(element, &block)
      return false if block.arity != 1
      @sax_parser.on_tag_open(element, block)
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
          chunk.force_encoding('UTF-8')

          @parser << chunk

          @bytes += chunk.length
          
          if not @sax_parser.is_closed?
            if @file
              @file << chunk
            end
          else
            if @file
              last_index = chunk.index('</ad>') + 4
              begin
                @file << chunk[0..last_index]
                @file << "</#{self.root}>"
              ensure
                @file.close
              end
            end

            EM.stop
          end
        }
        http.callback {
          if @file
            @file.close
          end
          EM.stop }
        end
      end
    end
  end
end

#require 'stringio'
#str = StringIO.new
#z = Zlib::GzipWriter.new(str)
#z.write(txt)
#z.close
