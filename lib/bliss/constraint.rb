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
                @state = :not_passed
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
        when :tag_name_required
          if @state == :not_checked
            @state = :not_passed
          end
      end
    end

    def detail
      self.ended! # TODO esto es una chota de codigo groncho!

      case @state
        when :not_passed
          case @setting
            when :tag_name_required
              [@depth, "missing"]
            #when :not_blank
            #  [@field.join(" or "), "blank"]
            #when :possible_values
            #  [@field.join(" or "), "invalid"]
          end
        when :passed
          case @setting
            when :tag_name_required, :tag_name_suggested
              [@depth, "exists"]
          end
        when :not_checked
          case @setting
            when :tag_name_suggested
              [@depth, "missing"]
          end
      end
    end

    def reset!
      @state = :not_checked
    end

    #def self.build_constraint(depth, setting, params={})#, field, type, possible_values=nil)
    #  constraints = []
      #constraints.push Bliss::Constraint.new(field, :exist) if types.include?(:exist)
      #constraints.push Bliss::Constraint.new(field, :not_blank) if types.include?(:not_blank)
      #constraints.push BlissConstraint.new(field, :possible_values, possible_values) if types.include?(:possible_values)
    #  constraints
    #end
  end
end
