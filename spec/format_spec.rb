require 'spec_helper'
#require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
#require_dependency 'xmlrpc/client'

describe Bliss::Format do
  before do
    @format = Bliss::Format.new(File.dirname(__FILE__) + '/../spec.yml')
  end

  describe '.constraints' do
    it 'should do it' do
      @format.constraints.should be_a(Array)
      #@format.constraints.size.should == 8
    end
  end
end
