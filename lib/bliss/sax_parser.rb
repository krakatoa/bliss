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

      value_at = @nodes.value_at_chain(@depth)

      if value_at.is_a? NilClass
        current[element] = {}
      #elsif value_at.is_a? Array
      #  current[element] = current.last
      elsif value_at.is_a? Hash
        if value_at.size == 0
          current[element] = [current[element]]
        else
          current[element] = [current[element], {}]
        end
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

      #current = @nodes.pair_at_chain(@depth)
      #puts current.inspect
      #puts @nodes.value_at_chain(@depth).class

      #case @nodes.value_at_chain(@depth).class
      #  when NilClass
      #    current[element] = @current_content
      #  when String
      #    current[element] = [current[element]]
      #    current[element].push @current_content
      #  when Array
      #    current[element].push @current_content
      #end

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
