require 'spec_helper'

describe Bliss::Constraint do
  describe 'run!' do
    it 'should pass' do
      constraint = Bliss::Constraint.new("root", :tag_name_required)
      constraint.run!({'root' => {'tag_1' => 'test', 'tag_2' => 'test'}})
      constraint.state.should == :passed
    end
    
    it 'should pass too' do
      constraint = Bliss::Constraint.new("(root|ROOT)", :tag_name_required)
      constraint.run!({'ROOT' => {'tag_1' => 'test', 'tag_2' => 'test'}})
      constraint.state.should == :passed
    end

    it 'should not pass' do
      constraint = Bliss::Constraint.new("(root|ROOT)", :tag_name_required)
      constraint.run!({'another' => {'tag_1' => 'test', 'tag_2' => 'test'}})
      constraint.state.should == :not_passed
    end
  end
end
