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

  describe '#settings_to_constraints' do
    it 'should return an array with a Bliss::Constraint object' do
      constraints = Bliss::Format.settings_to_constraints(['root'], {'tag_name_required' => true})
      constraints.should be_a(Array)
      constraints.size.should == 1
      constraints.first.should be_a(Bliss::Constraint)
    end

    it 'should have depth and setting loaded' do
      constraints = Bliss::Format.settings_to_constraints(['root'], {'tag_name_required' => true})
      constraints.first.depth.should == 'root'
      constraints.first.setting.should == :tag_name_required
    end

    it 'should have multiple depths' do
      constraints = Bliss::Format.settings_to_constraints(['root'], {'tag_name_required' => true, 'tag_name_values' => ['root', 'ROOT']})
      constraints.first.depth.should == '(root|ROOT)'
      constraints.first.setting.should == :tag_name_required
    end
  end
end
