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
        if !@@keywords.include?(depth.last)
          settings = @specs.value_at_chain(depth).select{|key| @@keywords.include?(key) }
        end
        if settings
          settings.merge!({"tag_name_required" => true}) if not settings.has_key?("tag_name_required")

          #puts settings.inspect

          # tag_name_required constraint:

          settings.each_pair { |setting, value|
            case setting
              when "tag_name_required"
                if value == true
                  @constraints.push(Bliss::Constraint.new(depth, :tag_name_required))
                end
            end
          }

          # check tag_name_values setting: OR on tag_name_required constraint

          puts "#{depth.join('/')}: #{settings.inspect}"
        end
      end

      #puts @constraints.inspect
      
      return @constraints
    end

    def open_tag_constraints(depth)
      # raise error if not depth.is_a? Array
      begin
        to_check_constraints = self.to_check_constraints.select {|c| [:tag_name_required].include?(c.setting) }.select {|c| (c.depth == depth) }
      rescue
        []
      end
    end

    def close_tag_constraints(depth)
      # raise error if not depth.is_a? Array
      begin
        to_check_constraints = self.to_check_constraints.select {|c| (c.depth - [c.depth[-1]]) == depth }
      rescue
        []
      end
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
      @constraints.collect(&:detail)
    end

    def error_details
      @constraints.select {|c| c.state == :not_passed }.collect(&:detail)
    end
    
    # reset_constraints_state
    # build_constraints
    
  end
end
