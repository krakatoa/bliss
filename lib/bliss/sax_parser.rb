module Bliss
  class SaxParser < Nokogiri::XML::SAX::Document
    def initialize
      @depth = []
      # @settings = {} # downcased

      @root = nil
      @nodes = {}
      @current_node = {}

      @on_root = nil

      @on_tag_open = {}
      @on_tag_close = {}

      @closed = false

    end

    def on_root(&block)
      @on_root = block
    end

    def on_tag_open(element, block)
      @on_tag_open.merge!({element => block})
    end

    def on_tag_close(element, block)
      @on_tag_close.merge!({element => block})
    end

    def close
      @closed = true
    end

    def is_closed?
      @closed
    end

    def start_element(element, attributes)
      # element_transformation

      if @root == nil
        @root = element
        if @on_root.is_a? Proc
          @on_root.call(@root)
        end
      end

      @depth.push(element) if @depth.last != element
      
      if @on_tag_open.has_key? element
        @on_tag_open[element].call(@depth)
      elsif @on_tag_open.has_key? 'default'
        @on_tag_open['default'].call(@depth)
      end

      current = @nodes.pair_at_chain(@depth)

      value_at = @nodes.value_at_chain(@depth)
      
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
      
      if @on_tag_close.has_key? element
        @on_tag_close[element].call(value_at)
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
