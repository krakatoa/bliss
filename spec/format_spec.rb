require 'spec_helper'
#require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
#require_dependency 'xmlrpc/client'

describe Bliss::Format do
  before do
    #@openx_banner = mock(OpenX::Services::Banner)
    @format = Bliss::Format.new
  end

  describe '.constraints' do
    #before do
    #end
    
    it 'should do it' do
      @format.constraints.size.should == 8
    end
  end

  #describe '.traffic' do
  #  before do
  #    @openx_banner.stub(:statistics) { YAML.load_file('spec/fixtures/openx_banner_statistics.yml') }
  #    OpenX::Services::Banner.should_receive(:find).with(1).and_return(@openx_banner)
  #    @banner = Banner.new(1)
  #  end

  #  it 'should return statistics' do
  #    @banner.traffic(Date.today, Date.today).should be_kind_of(Hash)
  #  end
  #end

  # describe '.created' do
  #   context 'when last creation is less than 2 days ago' do
  #     before do
  #       @site.stub(:last_creation_day_in_week) { Date.today - 1 }
  #     end

  #     it 'should be ok' do
  #       @site_evaluation.created[@site.id]['created'][0].should == 'ok'
  #     end
  #   end

  #   context 'when last creation is between 2 and 7 days ago' do
  #     before do
  #       @site.stub(:last_creation_day_in_week) { Date.today - 3 }
  #     end

  #     it 'should be a warning' do
  #       @site_evaluation.created[@site.id]['created'][0].should == 'warning'
  #     end
  #   end

  #   context 'when last creation is more than 7 days ago' do
  #     before do
  #       @site.stub(:last_creation_day_in_week) { Date.today - 8 }
  #     end

  #     it 'should be an alert' do
  #       @site_evaluation.created[@site.id]['created'][0].should == 'alert'
  #     end
  #   end
  # end
end
