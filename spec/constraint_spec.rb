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

    context "multiple depth levels" do
      it "should pass" do
        constraint = Bliss::Constraint.new("(root|ROOT)/id", :tag_name_required)
        constraint.run!({'id' => 'test', 'tag_2' => 'test'})
        constraint.state.should == :passed
      end
      
      it "should not pass" do
        constraint = Bliss::Constraint.new("(root|ROOT)/id", :tag_name_required)
        constraint.run!({'root' => {'tag_1' => 'test', 'tag_2' => 'test'}})
        constraint.state.should == :not_passed
      end
    end
  end

  describe '#settings_to_constraints' do
    it 'should return an array with a Bliss::Constraint object' do
      constraints = Bliss::Constraint.build_from_settings(['root'], {'tag_name_required' => true})
      constraints.should be_a(Array)
      constraints.size.should == 1
      constraints.first.should be_a(Bliss::Constraint)
    end

    it 'should have depth and setting loaded' do
      constraints = Bliss::Constraint.build_from_settings(['root'], {'tag_name_required' => true})
      constraints.first.depth.should == 'root'
      constraints.first.setting.should == :tag_name_required
    end

    it 'should have multiple depths' do
      constraints = Bliss::Constraint.build_from_settings(['root'], {'tag_name_required' => true, 'tag_name_values' => ['root', 'ROOT']})
      constraints.first.depth.should == '(root|ROOT)'
      constraints.first.setting.should == :tag_name_required
    end
  end
end
