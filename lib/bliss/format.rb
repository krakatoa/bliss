require 'yaml'

module Bliss
  class Format

    def initialize(filepath)
      self.specifications = YAML.load_file(filepath)
      @constraint_set = Bliss::ConstraintSet.new(@specs)
    end

    def specifications=(specs={})
      @specs = specs.dup
    end
    alias :specs= :specifications=

    def constraints
      @constraint_set.constraints
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
