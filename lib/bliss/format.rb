require 'yaml'

module Bliss
  class Format
    @@keywords = %w{ tag_name_required content_required tag_name_type content_type tag_name_format content_format tag_name_values content_values  }

    def initialize
      yml = YAML.load_file('/home/fernando/desarrollo/workspace/experimentos/bliss/spec.yml')
      self.specifications = yml
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

          #puts settings.inspect

          #depth_name = nil
          #setting_to_constraints(depth, settings).each { |cc|
            #cc.depth = depth_name
          #  @constraints.push(cc) #Bliss::Constraint.new(depth_name, cc.setting))
          #}
          @constraints.concat(Bliss::Format.settings_to_constraints(depth, settings))

        end
      end

      return @constraints
    end

    def self.settings_to_constraints(depth, settings)
      # TODO perhaps the Constraint model should handle this
      # e.g., constraint.add_depth (as array)
      # then internally it creates xpath-like depth

      current_constraints = []
      depth_name = nil
      #puts "#{depth.join('/')}: #{settings.inspect}"
      settings.each_pair { |setting, value|
        case setting
          when "tag_name_required"
            if value == true
              depth_name ||= depth.join('/')
              current_constraints.push(Bliss::Constraint.new(depth_name, :tag_name_required))
            end
          when "tag_name_values"
            depth_name = depth[0..-2].join('/')
            depth_name << "/" if depth_name.size > 0
            depth_name << "(#{value.join('|')})" # TODO esto funciona solo en el ultimo step del depth :/
        end
      }
      current_constraints.each {|cc|
        cc.depth = depth_name
      }
      current_constraints
    end

    #def open_tag_constraints(depth)
    #  # raise error if not depth.is_a? Array
    #  begin
    #    to_check_constraints = self.to_check_constraints.select {|c| [:tag_name_required].include?(c.setting) }.select {|c| Regexp.new(c.depth).match(depth) }
    #  rescue
    #    []
    #  end
    #end

    #def close_tag_constraints(depth)
    #  # raise error if not depth.is_a? Array
    #  begin
    #    to_check_constraints = self.to_check_constraints.select {|c| Regexp.new(c.depth.split('/')[0..-2].join('/')).match(depth) }
    #  rescue
    #    []
    #  end
    #end

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
      @constraints.collect(&:detail)
    end

    def error_details
      @constraints.select {|c| c.state == :not_passed }.collect(&:detail)
    end

    # reset_constraints_state
    # build_constraints

  end
end
