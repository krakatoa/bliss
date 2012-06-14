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

      @constraints = []

      @closed = false

    end

    def constraints(constraints)
      @constraints = constraints
    end

    def on_root(&block)
      @on_root = block
    end

    def on_tag_open(element, block)
      @on_tag_open.merge!({Regexp.new("#{element}$") => block})
    end

    def on_tag_close(element, block)
      # TODO
      # check how do we want to handle on_tag_close depths (xpath, array, another)
      @on_tag_close.merge!({Regexp.new("#{element}$") => block})
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
      
      #if @depth.last == 'ad'
        #puts search_key
        #puts value_at.keys.inspect
        #ad array #puts @constraints.select{|c| search_key.match(Regexp.new("#{c.depth.split('/').join('/')}$"))}.inspect
        #puts current.keys.inspect
        # others puts @constraints.select{|c| search_key.match(Regexp.new("#{c.depth.split('/')[0..-2].join('/')}$"))}.inspect
      #end

      @on_tag_close.keys.select{ |r| search_key.match(r) }.each do |reg|
        if value_at.empty?
          @on_tag_close[reg].call(current, @depth)
        else
          @on_tag_close[reg].call(value_at, @depth)
        end
      end
      # TODO constraint should return Regexp like depth too

      #puts @constraints.collect(&:state).inspect
      
      #puts @constraints.collect{|c| "#{c.depth}" }
      #puts @constraints.collect{|c| "#{c.depth.split("/").join('/')}" }

      @constraints.select{|c| [:not_checked, :passed].include?(c.state) }.select {|c| search_key.match(Regexp.new("#{c.depth.split('/').join('/')}$")) }.each do |constraint|
        #puts "search_key: #{search_key}"
        #puts "value_at.inspect: #{value_at.inspect}"
        #puts "current.inspect: #{current.inspect}"

        constraint.run!(current)
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
      #puts @nodes.inspect
    end
  end
end
