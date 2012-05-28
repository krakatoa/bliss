#require 'spec_helper'
#
#describe Site do
#  before { @site = Site.new }
#
#  describe '.last_creation_day_in_week' do
#    context 'with creations done today' do
#      before do
#        @site.stub(:crawls_created_between_dates) {
#          {       Date.today.to_time => 5,
#            (Date.today - 1).to_time => 0,
#            (Date.today - 2).to_time => 0,
#            (Date.today - 3).to_time => 0,
#            (Date.today - 4).to_time => 5
#          }
#        }
#      end
#
#      it 'should return today' do
#        @site.last_creation_day_in_week.should == Date.today
#      end
#    end
#
#    context 'with more than one day and less than eight days having 0 creations' do
#      before do
#        @site.stub(:crawls_created_between_dates) {
#          {       Date.today.to_time => 0,
#            (Date.today - 1).to_time => 0,
#            (Date.today - 2).to_time => 0,
#            (Date.today - 3).to_time => 0,
#            (Date.today - 4).to_time => 5
#          }
#        }
#      end
#
#      it 'should return last creation day' do
#        @site.last_creation_day_in_week.should == (Date.today - 4)
#      end
#    end
#
#    context 'when no crawls exists in week' do
#      before do
#        @site.stub(:crawls_created_between_dates) { Hash.new }
#      end
#
#      it 'should return Date.today - 8' do
#        @site.last_creation_day_in_week.should == (Date.today - 8)
#      end
#    end
#  end
#end
