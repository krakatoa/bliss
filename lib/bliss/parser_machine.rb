require "nokogiri"
module Bliss
  class ParserMachine < Nokogiri::XML::SAX::Document
    def initialize(parser)
      @depth = []
      # @settings = {} # downcased

      @root = nil
      @nodes = {}
      @current_node = {}

      @on_root = nil

      @on_tag_open = {}
      @on_tag_close = {}

      #@constraints = []
      @ignore_close = []

      @parser = parser

      @closed = false

    end

    def current_depth
      @depth
    end

    #def constraints(constraints)
      #@constraints = constraints
    #end

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

			###
			if @depth.size == 1
				current = @nodes.pair_at_chain(@depth[0..-2])
				value_at = @nodes.value_at_chain(@depth[0..-2])
			else
      	current = @nodes.pair_at_chain(@depth)
      	value_at = @nodes.value_at_chain(@depth)
			end

			#	puts "start_element-INITS@#{@depth.inspect}"
			#	puts "nodes: #{@nodes.inspect}"
			#	puts "current: #{current.inspect}"
			#	puts "valueAt: #{value_at.inspect}"
			
			#puts "depth: #{@depth.inspect},"
			#puts "starts: #{@nodes.inspect}"
			#puts "\n"
      
			if current.is_a? Array
				current = current.last
			end
      if current.is_a? Hash
				exists = true if current[element]
				if exists
					#puts "nodo ya existe"
					if current[element].is_a? Array
						current[element].concat [{}]
					else
						# TODO use this code to collect elements as batches
						current[element] = [current[element], {}]
						# DO NOT REMOVE
					end
				else
					current[element] = {}
				end
			elsif current.is_a? NilClass
				@nodes[element] = {}
      end

			#puts "depth: #{@depth.inspect},"
			#puts "finishes: #{@nodes.inspect}"
			#puts "\n"
			
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

    def ignore_next_close(tag)
      @ignore_close.push(tag)
    end

    def current_node
      current = @nodes.pair_at_chain(@depth[0..-2]).dup
      value_at = @nodes.value_at_chain(@depth[0..-2]).dup

      #if value_at.is_a? Hash
      #  current[element] = @current_content if @current_content.size > 0
      #elsif value_at.is_a? NilClass
      #  if current.is_a? Array
      #    current = current.last
      #    current[element] = @current_content if @current_content.size > 0
      #  end
      #end
      
      current_node = nil
      if value_at.empty? #|| value_at.strip == ''
        current_node = current #@on_tag_close[reg].call(current, @depth)
      else
        current_node = value_at #@on_tag_close[reg].call(value_at, @depth)
      end
			if current_node.is_a? Array
				current_node = current_node.last
			end
      current_node[@depth.last] = ""
      current_node
    end

    def end_element(element, attributes=[])
      return if is_closed?
      # element_transformation

      current = @nodes.pair_at_chain(@depth)
      value_at = @nodes.value_at_chain(@depth)
			#if @depth.last == "id"
			#	puts "ending@#{@depth.inspect}"			
			#	puts "nodes: #{@nodes.inspect}"
			#	puts "current: #{current.inspect}"
			#	puts "value_at: #{value_at.inspect}"
			#	puts "\n"
			#end

			if current.is_a? Array
				current = current.last
			end
			if current.is_a? Hash
				if (value_at.is_a? Hash and value_at.size == 0) #or value_at.is_a? NilClass
					current[element] = @current_content if @current_content.size > 0
				end
				#if value_at.is_a? Array #or !(value_at.last.is_a? Hash and value_at.size == 0)
				override = true if value_at.is_a?(Array)
				override = false if value_at.is_a?(Array) and value_at.last.is_a?(Hash) and value_at.last.size > 0
				if override
					current[element][-1] = @current_content if @current_content.size > 0
				end
			end
      @current_content = ''

      # TODO search on hash with xpath style
      # for example:
      # keys: */ad/url
      # keys: root/ad/url
      # @on_tag_close.keys.select {|key| @depth.match(key)}
      ##

			#if @depth.last == "id"
			#	puts "ended@#{@depth.inspect}"			
			#	puts "nodes: #{@nodes.inspect}"
			#	puts "current: #{current.inspect}"
			#	puts "value_at: #{value_at.inspect}"
			#	puts "\n"
			#end

      search_key = @depth.join('/') # element
      
      #if @depth.last == 'ad'
        #puts search_key
        #puts value_at.keys.inspect
        #ad array #puts @constraints.select{|c| search_key.match(Regexp.new("#{c.depth.split('/').join('/')}$"))}.inspect
        #puts current.keys.inspect
        # others puts @constraints.select{|c| search_key.match(Regexp.new("#{c.depth.split('/')[0..-2].join('/')}$"))}.inspect
      #end

      @on_tag_close.keys.select{ |r| search_key.match(r) }.each do |reg|
        #puts "search_key: #{search_key.inspect}"
        if @ignore_close.include? search_key
          @ignore_close.delete(search_key)
        else
					if value_at.is_a? Array
						value_at = value_at.last
					end
          if value_at.is_a? NilClass or value_at.empty?
            @on_tag_close[reg].call(current.dup, @depth)
          else
            @on_tag_close[reg].call(value_at.dup, @depth)
          end
        end
      end
      # TODO constraint should return Regexp like depth too

      #puts @constraints.collect(&:state).inspect
      
      #puts @constraints.collect{|c| "#{c.depth}" }
      #puts @constraints.collect{|c| "#{c.depth.split("/").join('/')}" }

      @parser.formats.each do |format|
        format.constraints.select{|c| [:not_checked, :passed].include?(c.state) }.select {|c| search_key.match(Regexp.new("#{c.depth.split('/').join('/')}$")) }.each do |constraint|
          #puts "search_key: #{search_key}"
          #puts "value_at.inspect: #{value_at.inspect}"
          #puts "current.inspect: #{current.inspect}"
          constraint.run!(current)
        end
      end

      @depth.pop if @depth.last == element
    end

    def concat_content(string)
      if string
        @current_content << string
      end
    end

    def end_document

      #puts @nodes.inspect
    end
  end
end
