require 'yaml'

module Bliss
  class Format
    @@keywords = %w{ tag_name_required content_required tag_name_type content_type tag_name_format content_format tag_name_values content_values  }

    def initialize(filepath)
      self.specifications = YAML.load_file(filepath)
    end

    # TODO for debugging only!
    def keywords
      @@keywords
    end

    def specifications=(specs={})
      @specs = specs.dup
    end
    alias :specs= :specifications=

    def constraints
      return [] if not (@specs.is_a? Hash and @specs.size > 0)
      return @constraints if @constraints

      @constraints = []

      @specs.recurse(true) do |depth, value|
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
            value_at_c = @specs.value_at_chain(depth[0..i])
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
          @constraints.concat(Bliss::Constraint.build_from_settings(indepth, settings))

        end
      end

      return @constraints
    end

    # constraint set model? constraints.valid.with_depth(['root', 'ads']) ???
    def to_check_constraints
      # raise error if not depth.is_a? Array
      begin
        to_check_constraints = constraints.select {|c| [:not_checked, :passed].include?(c.state) }
        to_check_constraints
      rescue
        []
      end
    end

    def details
      constraints.collect(&:detail)
    end

    def index
      # Returns an Array with the states of the current constraint_set in the form of:
      # [ not_passed, passed, not_checked ]
      # TODO it needs the constraint to be ended!, very ugly
      [
        constraints.count {|c| c.state == :not_passed},
        constraints.count {|c| c.state == :passed},
        constraints.count {|c| c.state == :not_checked}
      ]
    end

    def error_details
      constraints.select {|c| c.state == :not_passed }.collect(&:detail)
    end

    def reset_constraints_state
      return false if not @constraints
      @constraints.each {|c| c.reset!}
    end

    # reset_constraints_state
    # build_constraints

  end
end
