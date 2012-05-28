module Bliss
  class ParserMachine < Nokogiri::XML::SAX::Document
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
      @on_tag_open.merge!({Regexp.new(element) => block})
    end

    def on_tag_close(element, block)
      @on_tag_close.merge!({Regexp.new(element) => block})
    end

    def close
      @closed = true
    end

    def is_closed?
      @closed
    end

    def start_element(element, attributes)
      return if is_closed?
      # element_transformation

      if @root == nil
        @root = element
        if @on_root.is_a? Proc
          @on_root.call(@root)
        end
      end

      @depth.push(element) if @depth.last != element
      
      # TODO search on hash with xpath style
      # for example:
      # keys: */ad/url
      # keys: root/ad/url
      # @on_tag_close.keys.select {|key| @depth.match(key)}

      # other example:
      # keys: root/(ad|AD)/description
      ##

      search_key = @depth.join('/') # element
      @on_tag_open.keys.select{ |r| search_key.match(r) }.each do |reg|
        @on_tag_open[reg].call(@depth)
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

=begin
    def open_tag_regexps
      return @open_tag_regexps if @open_tag_regexps

      @open_tag_regexps = @on_tag_open.keys.collect {|key| Regexp.new(key) }
      @open_tag_regexps
    end
    
    def close_tag_regexps
      return @close_tag_regexps if @close_tag_regexps

      @close_tag_regexps = @on_tag_close.keys.collect {|key| Regexp.new(key) }
      @close_tag_regexps
    end
=end

    def characters(string)
      return if is_closed?
      concat_content(string)
    end

    def cdata_block(string)
      return if is_closed?
      concat_content(string)
    end

    def end_element(element, attributes=[])
      return if is_closed?
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

      # TODO search on hash with xpath style
      # for example:
      # keys: */ad/url
      # keys: root/ad/url
      # @on_tag_close.keys.select {|key| @depth.match(key)}
      ##
      
      search_key = @depth.join('/') # element
      @on_tag_close.keys.select{ |r| search_key.match(r) }.each do |reg|
        @on_tag_close[reg].call(value_at, @depth)
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
