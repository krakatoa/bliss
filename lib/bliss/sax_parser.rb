module Bliss
  class SaxParser < Nokogiri::XML::SAX::Document
    def initialize
      @depth = []
      # @settings = {} # downcased

      @nodes = {}
      @current_node = {}
    end

    #def on_element(element, &block)
    #end

    def start_element(element, attributes)
      # element_transformation
      @depth.push(element) if @depth.last != element
      
      current = @nodes.pair_at_chain(@depth)

      puts element
      puts @depth.inspect
      puts @nodes.inspect

      case @nodes.value_at_chain(@depth).class
        when String
          current[element] = [current[element]]
          current[element].push @current_content
        when Array
          current[element].push @current_content
        when Hash
          puts 'hash'
      end

      @current_content = ''
    end

    def characters(string)
      concat_content(string)
    end

    def cdata_block(string)
      concat_content(string)
    end

    def end_element(element, attributes=[])
      # element_transformation

      current = @nodes.pair_at_chain(@depth)
      #puts current.inspect
      #puts @nodes.value_at_chain(@depth).class

      case @nodes.value_at_chain(@depth).class
        when NilClass
          current[element] = @current_content
        when String
          current[element] = [current[element]]
          current[element].push @current_content
        when Array
          current[element].push @current_content
      end

      @depth.pop if @depth.last == element
    end

    def concat_content(string)
      string.strip!
      if string
        @current_content << string
      end
    end

    def end_document
      puts @nodes.inspect
    end
  end
end
