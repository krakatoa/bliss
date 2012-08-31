module Bliss
  class ParserMachineBuilder
    def initialize(parser)
      @parser = parser
      
      @on_tag_open = nil
      @on_tag_close = nil
      @on_error = nil
    end

    def on_error(&block)
      raise "#on_error block expects two args, |error_type, details|" if block.arity != 2
      @on_error = block
    end

    def error_callback_defined?
      @on_error.is_a?(Proc) ? true : false
    end

    def call_on_error(error_type, details={})
      @on_error.call(error_type, details)
    end

    def on_tag_open(element='.', block)
      return false if block.arity != 1
      @on_tag_open ||= {}
      @on_tag_open[element] = block
    end
    
    def on_tag_close(element='.', block)
      return false if block.arity < 1
      @on_tag_close ||= {}
      @on_tag_close[element] = block
    end
    
    def initialize_on_tag_open(parser_machine)
      return if not @on_tag_open

      @on_tag_open.each {|el, bl|
        overriden_block = Proc.new { |depth|
          if not el == 'default'
            @parser.reset_unhandled_bytes
          end

          bl.call(depth)
        }
        parser_machine.on_tag_open(el, overriden_block)
      }
    end

    def initialize_on_tag_close(parser_machine)
      return if not @on_tag_close
      @on_tag_close.each {|el, bl|
        overriden_block = Proc.new { |hash, depth|
          @parser.reset_unhandled_bytes

          bl.call(hash, depth)
        }
        parser_machine.on_tag_close(el, overriden_block)
      }
    end

    def build_parser_machine
      parser_machine = Bliss::ParserMachine.new(@parser)
      push_parser = Nokogiri::XML::SAX::PushParser.new(parser_machine)
      initialize_on_tag_open(parser_machine)
      initialize_on_tag_close(parser_machine)
      return parser_machine, push_parser
    end
    
  end
end
