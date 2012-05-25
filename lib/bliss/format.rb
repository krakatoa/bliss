module Bliss
  class Format
    def initialize
      yml = YAML.load_file('/home/fernando/desarrollo/workspace/experimentos/bliss/spec.yml')
      specifications= yml
    end

    def specifications=(specs={})
      @specs = specs.dup
    end
    alias :specs= :specifications=

    def constraints
      return [] if not (@specs.is_a? Array and @specs.size > 0)

      @specs
    end
    
    # during parsing
    # Sumavisos::Parsers::Validator.check_constraints(ad, constraints.select{|c| [:not_checked, :passed].include?(c.state)})

    # @constraints.select{|c| c.state == :not_passed }.collect(&:detail)
    
    def ad_constraints(root, vertical)
      required_fields = Sumavisos::Parsers::Validator::FIELDS['all']['required'].dup
      required_fields.concat(Sumavisos::Parsers::Validator::FIELDS[vertical]['required'])
      
      constraints = []
      required_fields.each do |field|
        constraints.concat(Sumavisos::Parsers::Constraint.build_constraint(field, [:exist, :not_blank]).dup)
      end

      if vertical == 'property'
        constraints.concat(Sumavisos::Parsers::Constraint.build_constraint(['type'], [:possible_values], Sumavisos::Parsers::Validator::VALID_PROPERTY_TYPES).dup)
      end

      constraints
    end

    def check_constraints(ads, constraints)
      errors = []

      ads = [ads] if not ads.is_a? Array

      ads.each do |ad|
        constraints.each do |constraint|
          constraint.run!(ad)
        end
      end

      return errors
    end
  end
end
