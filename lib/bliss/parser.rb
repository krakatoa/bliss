module Bliss
  class Parser
    attr_reader :header
    attr_reader :push_parser
    attr_reader :parser_machine
    attr_accessor :unhandled_bytes

    def initialize(path, filepath=nil)
      @path = path
      
      #@parser_machine = Bliss::ParserMachine.new(self)

      #@push_parser = Nokogiri::XML::SAX::PushParser.new(@parser_machine)

      if filepath
        @file = File.new(filepath, 'w')
        @file.autoclose = false
      end

      @header = nil
      @root = nil
      @nodes = nil
      @formats = []

      @on_tag_open = {}
      @on_tag_close = {}
      @zstream = nil

      #on_root {}
    end

    def add_format(format)
      @formats.push(format)
    end

    def formats
      @formats
    end

    #def load_constraints_on_parser_machine
    #  @parser_machine.constraints(@formats.collect(&:constraints).flatten)
    #end

    def current_depth
      @parser_machine.current_depth
    end

    def current_node
      @parser_machine.current_node
    end

    def formats_details
      #@formats.each do |format|
      #  puts format.details.inspect
      #end
      @formats.collect(&:details)
    end

    def formats_index
      @formats.collect(&:index)
    end

=begin
    # deprecate this, use depth at on_tag_open or on_tag_close instead
    def on_root(&block)
      return false if not block.is_a? Proc
      @parser_machine.on_root { |root|
        @root = root
        block.call(root)
      }
    end
=end

    def on_tag_open(element='.', &block)
      return false if block.arity != 1
      @on_tag_open[element] = block
    end

    def initialize_on_tag_open
      return if not @on_tag_open

      @on_tag_open.each {|el, bl|
        overriden_block = Proc.new { |depth|
          if not el == 'default'
            reset_unhandled_bytes
          end

          bl.call(depth)
        }
        @parser_machine.on_tag_open(el, overriden_block)
      }
    end

    def on_tag_close(element='.', &block)
      return false if block.arity < 1
      @on_tag_close[element] = block
    end

    def initialize_on_tag_close
      return if not @on_tag_close
      @on_tag_close.each {|el, bl|
        overriden_block = Proc.new { |hash, depth|
          reset_unhandled_bytes

          bl.call(hash, depth)
        }
        @parser_machine.on_tag_close(el, overriden_block)
      }
    end

    def initialize_push_parser
      #puts "Initializing PushParser\n"
      @parser_machine = Bliss::ParserMachine.new(self)
      @push_parser = Nokogiri::XML::SAX::PushParser.new(@parser_machine)
      initialize_on_tag_open
      initialize_on_tag_close
      reset_unhandled_bytes
      #puts "Initialized. PushParser (#{self.parser_machine.inspect})\n"
    end

    def on_max_unhandled_bytes(bytes, &block)
      @max_unhandled_bytes = bytes
      @on_max_unhandled_bytes = block
    end

    def on_timeout(seconds, &block)
      @timeout = seconds
      @on_timeout = block
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
        if @on_max_unhandled_bytes
          @on_max_unhandled_bytes.call
          @on_max_unhandled_bytes = nil
        end
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

    def set_header(header)
      return if header.empty?
      @header ||= header
    end

    def header
      @header
    end

    def zstream
      @zstream
    end

    def set_zstream=(zstream)
      @zstream = zstream
    end

    def root
      @root
    end

    def close
      @parser_machine.close
    end

    def parse
      reset_unhandled_bytes if check_unhandled_bytes?
      #load_constraints_on_parser_machine
      self.initialize_push_parser

      EM.run do
        http = nil
        if @timeout
          http = EM::HttpRequest.new(@path, :connect_timeout => @timeout, :inactivity_timeout => @timeout).get
        else
          http = EM::HttpRequest.new(@path).get
        end
        
        parser = self
        @autodetect_compression = true
        compression = :none
        if @autodetect_compression
          http.headers do
            if (/^attachment.+filename.+\.gz/i === http.response_header['CONTENT_DISPOSITION']) or ["application/octet-stream", "application/x-gzip", "application/gzip"].include? http.response_header['CONTENT_TYPE'] or http.response_header.compressed?
              parser.set_zstream = Zlib::Inflate.new(Zlib::MAX_WBITS+16)
              compression = :gzip
            end
          end
        end
        
        http.stream { |chunk|
          if chunk
            chunk.force_encoding('UTF-8')
            case compression
              when :gzip
                chunk = parser.zstream.inflate(chunk)
                chunk.force_encoding('UTF-8')
            end

            chunk.lines.each { |line|

              if parser.check_unhandled_bytes?
                parser.unhandled_bytes += line.length
                parser.check_unhandled_bytes
              end
            
              if not parser.parser_machine.is_closed?
                begin
                  if not parser.header
                    parser.set_header(line)
                  end
                  parser.push_parser << line
                rescue Nokogiri::XML::SyntaxError => e
                  if e.message.include?("encoding")
                    puts "Wrong encoding given:"
                    puts line
                    current_depth = parser.current_depth.dup
                    #puts parser.current_node.inspect

                    parser.initialize_push_parser
                    parser.push_parser << parser.header
                    #puts parser.header
                    current_depth[0..-2].each { |tag|
                      tag = "<#{tag}>"
                      #puts tag
                      parser.push_parser << tag
                    }
                    parser.parser_machine.ignore_next_close(current_depth[0..-2].join("/"))
                    puts "\n"
                    #raise Bliss::EncodingError, "Wrong encoding given"
                  end
                  next
                end
                if @file
                  @file << line
                end
              else
                if parser.exceeded?
                  #puts 'exceeded'
                  parser.secure_close
                else
                  if @file
                    if @wait_tag_close
                      #puts 'handle wait'
                      parser.handle_wait_tag_close(chunk) #if @wait_tag_close
                    else
                      #puts 'secure close'
                      parser.secure_close
                    end
                  end
                end
              end
            }
          end
        }
        http.errback {
          #puts 'errback'
          if @timeout
            @on_timeout.call
          end
          parser.secure_close
        }
        http.callback {
          #if @file
          #  @file.close
          #end
          #EM.stop
          parser.secure_close
        }
      end
      file_close
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

    def file_close
      if @file
        @file.close
      end
    end

    def secure_close
      begin
        if @zstream
          @zstream.close
        end
      rescue
      ensure
        EM.stop
        #puts "Closed secure."
      end
    end

  end
end
