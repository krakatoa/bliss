#encoding: utf-8

require 'spec_helper'
#require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
#require_dependency 'xmlrpc/client'

describe Bliss::Parser do
  #before do
  #  @parser = Bliss::Parser.new('http://www.topdiffusion.com/flux/topdiffusion_adsdeck.xml')
  #  @format = Bliss::Format.new(File.dirname(__FILE__) + '/../spec.yml')
  #  @parser.add_format(@format)
  #end

  context 'when parsing a valid document' do
    it "should parse" do
      mocked_request("<root><el>test</el></root>")
      
      @parser = Bliss::Parser.new('mock')

      count = 0
      @parser.on_tag_close { |hash, depth|
        count += 1
        case count
          when 1
            depth.should == ['root', 'el']
          when 2
            depth.should == ['root']
        end
      }
      @parser.parse
    end
  end

  context 'when parsing a document with encoding issues' do
    it "should throw an Exception and continue parsing" do
      #xml = <<-EOF
      #EOF

      xml = File.read(File.dirname(File.expand_path(__FILE__)) + "/../topdif.xml")

      mocked_request(xml)

      @parser = Bliss::Parser.new('mock', "test.xml")

      ads_count = 0
      @parser.on_tag_close("root/ad") { |hash, depth|
        puts "\n"
        puts "hash: #{hash.inspect}"
        ads_count += 1
        #puts depth.inspect
      }
      begin
        @parser.parse
      rescue Bliss::EncodingError  => err
        puts "Encoding error!"
      end
    end
  end

=begin
  context 'when parsing a valid document' do
    before do
      #begin
        count = 0
        @parser.on_tag_close('(trovit)/ads/ad') {
          count += 1
          if count == 10
            @parser.close
          end
        }
        @parser.parse
      #rescue
      #end
    end

    describe '.formats_details' do
      it 'should have all required keys as existing' do
        puts @parser.formats_details.inspect

      end
    end
  end
=end
end
