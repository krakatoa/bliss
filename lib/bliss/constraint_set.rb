module Bliss
  class ConstraintSet
    @@keywords = %w{ tag_name_required content_required tag_name_type content_type tag_name_format content_format tag_name_values content_values  }

    def initialize(specs)
      @constraints = Bliss::ConstraintSet.build_from_specs(specs)
    end

    def constraints
      @constraints
    end

    def not_checked
      begin
        to_check_constraints = constraints.select {|c| [:not_checked, :passed].include?(c.state) }
        to_check_constraints
      rescue
        []
      end
    end

    # TODO
    #   scope constraints by depth ?
    
    def self.build_from_specs(specs)
      return [] if not (specs.is_a? Hash and specs.size > 0)
      #return @constraints if @constraints

      constraints = []
      
      specs.recurse(true) do |depth, value|
        if value.is_a? Hash and !@@keywords.include?(depth.last)
          settings = value.select { |key| @@keywords.include?(key) }
        end
        #settings = @specs.value_at_chain(depth).select{|key| @@keywords.include?(key) }
        if settings.is_a? Hash and !@@keywords.include?(depth.last)
          settings.merge!({"tag_name_required" => true}) if not settings.has_key?("tag_name_required")

          # TODO this is an ugly way to move tag_name_values to the end!
          settings.store('tag_name_values', settings.delete('tag_name_values')) if settings.has_key?('tag_name_values')
          settings.store('content_values', settings.delete('content_values')) if settings.has_key?('content_values')

          # get extended depth
          indepth = []
          #puts "depth: #{depth}"
          depth.each_with_index { |v, i|
            value_at_c = specs.value_at_chain(depth[0..i])
            if value_at_c.is_a? Hash
              if value_at_c.has_key?('tag_name_values')
                indepth.push "(#{value_at_c['tag_name_values'].join("|")})"
              else
                indepth.push depth[i]
              end
            else
              #indepth.push depth.last
            end
          }
          constraints.concat(Bliss::Constraint.build_from_settings(indepth, settings))

        end
      end

      return constraints

    end
  end
end
