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

      #puts @depth.inspect
      current = @nodes.pair_at_chain(@depth)

      value_at = @nodes.value_at_chain(@depth)
      
      #if element == 'picture'
      #  puts current.inspect
      #  puts value_at.inspect
      #  puts '--\n'
      #end

      if current.is_a? Hash
        if value_at.is_a? NilClass
          current[element] = {}
        elsif value_at.is_a? Hash
          if current[element].is_a? Array
            current[element].concat [{}]
          else
            current[element] = [current[element], {}]
            #current = @nodes.pair_at_chain(@depth)
          end
        elsif value_at.is_a? Array
          #puts @depth.inspect
          #puts current[element].inspect
          #puts current[element].inspect
        end
      elsif current.is_a? Array
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
      value_at = @nodes.value_at_chain(@depth)

      if value_at.is_a? Hash
        current[element] = @current_content if @current_content.size > 0
      elsif value_at.is_a? NilClass
        if current.is_a? Array
          current = current.last
          current[element] = @current_content if @current_content.size > 0
        end
      end
      @current_content = ''
      
      if element == 'ad'
        puts "---\n"
        puts "---\n"
        puts @nodes.inspect
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
