module Bliss
  class Parser
    def initialize(path)
      @path = path
      @parser_machine = Bliss::ParserMachine.new(path)
    end

    def parse
      @parser_machine.parse
    end
  end
end
