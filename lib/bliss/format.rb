require 'yaml'

module Bliss
  class Format

    def initialize(filepath)
      specifications = YAML.load_file(filepath)

      @constraint_set = Bliss::ConstraintSet.new(specifications)
    end

    def constraints
      @constraint_set.constraints
    end

    def to_check_constraints
      @constraint_set.not_checked
      # raise error if not depth.is_a? Array
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

  end
end
