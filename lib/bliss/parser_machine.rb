module Bliss
  class ParserMachine
    attr_writer :max_unhandled_bytes

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

    def on_tag_open(element='default', &block)
      return false if block.arity != 1

      overriden_block = Proc.new { |depth|
        if not element == 'default'
          reset_unhandled_bytes
        end
        block.call(depth)
      }
      @sax_parser.on_tag_open(element, overriden_block)
    end

    def on_tag_close(element, &block)
      overriden_block = Proc.new { |hash|
        reset_unhandled_bytes
        block.call(hash)
      }
      @sax_parser.on_tag_close(element, overriden_block)
    end

    def wait_tag_close(element)
      @wait_tag_close = "</#{element}>"
    end

    def reset_unhandled_bytes
      return false if not check_unhandled_bytes?
      @unhandled_bytes = 0
    end

    def check_unhandled_bytes
      if @unhandled_bytes > @max_unhandled_bytes
        self.close
      end
    end

    def exceeded?
      return false if not check_unhandled_bytes?
      if @unhandled_bytes > @max_unhandled_bytes
        return true
      end
    end

    def check_unhandled_bytes?
      @max_unhandled_bytes ? true : false
    end

    def root
      @root
    end

    def close
      @sax_parser.close
    end

    def parse
      reset_unhandled_bytes if check_unhandled_bytes?

      EM.run do
        http = EM::HttpRequest.new(@path).get
        http.stream { |chunk|
          if chunk
            chunk.force_encoding('UTF-8')

            if check_unhandled_bytes?
              @unhandled_bytes += chunk.length
              check_unhandled_bytes
            end
            if not @sax_parser.is_closed?
              begin
                @parser << chunk
                if @file
                  @file << chunk
                end
              rescue Nokogiri::XML::SyntaxError => e
                #puts 'encoding error'
                if e.message.include?("encoding")
                  raise Bliss::EncodingError, "Wrong encoding given"
                end
              end

            else
              if exceeded?
                #puts 'exceeded'
                secure_close
              else
                if @file
                  if @wait_tag_close
                    #puts 'handle wait'
                    handle_wait_tag_close(chunk) #if @wait_tag_close
                  else
                    #puts 'secure close'
                    secure_close
                  end
                end
              end
            end
          end
        }
        http.errback {
          #puts 'errback'
          secure_close
        }
        http.callback {
          #puts 'callback'
          #if @file
          #  @file.close
          #end
          #EM.stop
          secure_close
        }
      end
    end
    
    def handle_wait_tag_close(chunk)
      begin
        last_index = chunk.index(@wait_tag_close)
        if last_index
          last_index += 4
          @file << chunk[0..last_index]
          @file << "</#{self.root}>" # TODO set this by using actual depth, so all tags get closed
          secure_close
        else
          @file << chunk
        end
      rescue
        secure_close
      end
    end

    def secure_close
      begin
        @file.close
      rescue
      ensure
        EM.stop
        #puts "Closed secure."
      end
    end

  end
end

#require 'stringio'
#str = StringIO.new
#z = Zlib::GzipWriter.new(str)
#z.write(txt)
#z.close
