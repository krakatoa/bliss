module Bliss
  class Constraint
    attr_accessor :depth, :possible_values
    attr_reader :setting, :state

    def initialize(depth, setting, params={})
      @depth = depth
      @setting = setting
      @possible_values = params[:possible_values].collect(&:to_s) if params.has_key?(:possible_values)

      @state = :not_checked
    end

    def tag_names
      @depth.split('/').last.gsub('(', '').gsub(')', '').split('|')
    end

    # TODO should exist another method passed! for tag_name_required ?
    def run!(hash=nil)
      @state = :not_checked
      #@field.each do |field|
        #if @state == :passed
        #  break
        #end
        case @setting
          when :tag_name_required, :tag_name_suggested
            content = nil
            if hash
              #puts "#{@depth.inspect} - required: #{required.inspect}"

              found = false
              self.tag_names.each do |key|
                if hash.keys.include?(key)
                  found = true
                  break
                end
              end
              if found
                @state = :passed
              else
                if @setting == :tag_name_required
                  puts "hash: #{hash.inspect}"
                  puts "self.tag_names: #{self.tag_names.inspect}"
                  @state = :not_passed
                end
              end
            else
              @state = :passed
            end
          when :content_values
            if hash
              found = false
              self.tag_names.each do |key|
                content = hash[key]
                #puts content
                #puts @possible_values.inspect
                if @possible_values.include?(content)
                  found = true
                  break
                end
              end
              if found
                @state = :passed
              else
                @state = :not_passed
              end
            end
          #when :not_blank
          #  if hash.has_key?(field) and !hash[field].to_s.empty?
          #    @state = :passed
          #  else
          #    @state = :not_passed
          #  end
        end
      #end
      @state
    end

    def ended!
      case @setting
        when :tag_name_required, :content_values
          if @state == :not_checked
            @state = :not_passed
          end
      end
    end

    def detail
      #self.ended! # TODO esto es una chota de codigo groncho!

      returned = case @state
        when :not_passed
          case @setting
            when :tag_name_required
              [@depth, "missing"]
            when :content_values
              [@depth, "invalid"]
            #when :not_blank
            #  [@field.join(" or "), "blank"]
            #when :possible_values
            #  [@field.join(" or "), "invalid"]
          end
        when :passed
          case @setting
            when :tag_name_required, :tag_name_suggested
              [@depth, "exists"]
            when :content_values
              [@depth, "valid"]
          end
        when :not_checked
          case @setting
            when :tag_name_suggested
              [@depth, "suggested"]
          end
      end
      returned
    end

    def reset!
      @state = :not_checked
    end

    # Builds a collection of constraints that represent the given settings
    #
    # @param [String] depth
    #   The tag depth on which the given constraints will work
    #
    # @param [Hash] settings
    #
    # @return [Array<Bliss::Constraint>] that represents the given settings
    #
    # @example
    #   Bliss::Constraint.build_from_settings(["root", "child"], {"tag_name_required" => false})
    #
    def self.build_from_settings(depth, settings)
      constraints = []

      depth_name = Bliss::Constraint.depth_name_from_depth(depth, settings["tag_name_values"])
      
      settings.each_pair { |setting, value|
        case setting
          when "tag_name_required"
            if value == true
              constraints.push(Bliss::Constraint.new(depth_name, :tag_name_required))
            else
              constraints.push(Bliss::Constraint.new(depth_name, :tag_name_suggested))
            end
          when "content_values"
            constraints.push(Bliss::Constraint.new(depth_name, :content_values, {:possible_values => value}))
        end
      }
      constraints
    end

    def self.depth_name_from_depth(depth, tag_name_values)
      depth_name = nil
      if not tag_name_values
        depth_name ||= depth.join('/')
      else
        # TODO esto funciona solo en el ultimo step del depth :/
        #   es decir, devolveria: root/(ad|item)
        #   pero nunca podria devolver: (root|base)/(ad|item)
        #
        #   una solucion seria la busqueda de bifurcaciones en las anteriores constraints para armar un depth_name completo

        depth_name = depth[0..-2].join('/')
        depth_name << "/" if depth_name.size > 0
        depth_name << "(#{tag_name_values.join('|')})"
      end
      
      # TODO Analyze creating a Depth model for handling of path/depth/tree during constraint creation
      # depth
      # {"root" => {"ad" => {}}}

      # path  => "root/(ad|item)"
      # depth => 2
      # tree  => {"root" => {["ad", "item"] => nil}}
      
      #   tree.recurse(true)
      # 

      return depth_name
    end

  end
end
