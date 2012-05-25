module Bliss
  class Format
    def initialize
    end

    alias :spec=,:specifications
    def specifications=(specs={})
      puts specs.inspect
    end
  end
end
