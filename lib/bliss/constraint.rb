module Bliss
  class Constraint
    attr_reader :field, :type, :state

    TYPES = [:exist, :not_blank, :possible_values]

    # TODO use depth on each constraint

    def initialize(field, type, possible_values=nil)
      if field.is_a? Array
        @field = field
      else
        @field = [field]
      end
      @type = type
      @possible_values = possible_values

      @state = :not_checked
    end

    def run!(hash)
      @state = :not_checked
      @field.each do |field|
        if @state == :passed
          break
        end
        case @type
          when :exist
            if !hash.keys.include?(field)
              @state = :not_passed
            else
              @state = :passed
            end
          when :not_blank
            if hash.has_key?(field) and !hash[field].to_s.empty?
              @state = :passed
            else
              @state = :not_passed
            end
          when :possible_values
            if hash.has_key?(field) and @possible_values.include?(hash[field])
              @state = :passed
            else
              @state = :not_passed
            end
        end
      end
      @state
    end

    def detail
      if @state == :not_passed
        detail = case @type
          when :exist
            [@field.join(" or "), "missing"]
          when :not_blank
            [@field.join(" or "), "blank"]
          when :possible_values
            [@field.join(" or "), "invalid"]
        end
      end
    end

    def self.build_constraint(field, types, possible_values=nil)
      constraints = []
      constraints.push Bliss::Constraint.new(field, :exist) if types.include?(:exist)
      constraints.push Bliss::Constraint.new(field, :not_blank) if types.include?(:not_blank)
      constraints.push BlissConstraint.new(field, :possible_values, possible_values) if types.include?(:possible_values)
      constraints
    end
  end
end
