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

      constraints = []

      @specs.recurse(true) do |depth, value|
        if !@@keywords.include?(depth.last)
          settings = @specs.value_at_chain(depth).select{|key| @@keywords.include?(key) }
        end
        if settings
          settings.merge!({"tag_name_required" => true}) if not settings.has_key?("tag_name_required")

          puts settings.inspect

          # tag_name_required constraint:

          settings.each_pair { |setting, value|
            case setting
              when "tag_name_required"
                if value == true
                  constraints.push(Bliss::Constraint.new(depth, :tag_name_required))
                end
            end
          }

          #required_fields.each do |field|
          #  constraints.concat(Sumavisos::Parsers::Constraint.build_constraint(field, [:exist, :not_blank]).dup)
          #end

          ###

          #puts "#{depth.join('/')}: #{settings.inspect}"
        end
      end

      puts constraints.inspect
      
      return constraints
    end
    
    # during parsing
    # Sumavisos::Parsers::Validator.check_constraints(ad, constraints.select{|c| [:not_checked, :passed].include?(c.state)})

    # @constraints.select{|c| c.state == :not_passed }.collect(&:detail)
    
    def ad_constraints(root, vertical)
      #required_fields = Sumavisos::Parsers::Validator::FIELDS['all']['required'].dup
      #required_fields.concat(Sumavisos::Parsers::Validator::FIELDS[vertical]['required'])
      
      #constraints = []
      #required_fields.each do |field|
      #  constraints.concat(Sumavisos::Parsers::Constraint.build_constraint(field, [:exist, :not_blank]).dup)
      #end

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
