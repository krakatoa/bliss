require 'spec_helper'
#require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
#require_dependency 'xmlrpc/client'

describe Bliss::Parser do
  before do
    @parser = Bliss::Parser.new('http://www.topdiffusion.com/flux/topdiffusion_adsdeck.xml')
    @format = Bliss::Format.new
    @parser.add_format(@format)
  end

  context 'when parsing a valid document' do
    before do
      begin
        @parser.parse
      rescue
      end
    end

    describe '.formats_details' do
      it 'should have all required keys as existing' do
        puts @parser.formats_details.inspect
      end
    end
  end
end
