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

		it "should read nested elements" do
			xml = <<-EOF
<root>
	<item>
		<container>
			<nested>1</nested>
			<nested>2</nested>
			<nested>3</nested>
		</container>
	</item>
</root>
EOF

      mocked_request(xml)
      
      @parser = Bliss::Parser.new('mock')

      ads = []
      
      @parser.on_tag_close("root/item/container/nested") { |hash, depth|
				#puts "depth: #{depth.inspect}"
				#puts hash.inspect
				#puts "\n"
        ads << hash
      }
      @parser.parse
			#puts ads.inspect
      
      ads.size.should == 3
		end
		
		it "should read containers of nested elements" do
			xml = <<-EOF
<root>
	<item>
		<container>
			<nested>1</nested>
			<nested>2</nested>
			<nested>3</nested>
		</container>
	</item>
	<item>
		<id>a</id>
		<container>
			<nested>4</nested>
			<nested>5</nested>
		</container>
	</item>
</root>
EOF

      mocked_request(xml)
      
      @parser = Bliss::Parser.new('mock')

      ads = []
      
      @parser.on_tag_close("root/item") { |hash, depth|
				#puts "on_tag_close@#{depth.inspect}"
				puts hash.inspect
				#puts "\n"
        ads << hash
      }
      @parser.parse
      ads.size.should == 2
			ads[0].should have_key("container")
			ads[0]["container"].should have_key("nested")
			ads[0]["container"]["nested"].should == ["1", "2", "3"]
			ads[1].should have_key("id")
			ads[1]["id"].should == "a"
			ads[1].should have_key("container")
			ads[1]["container"].should have_key("nested")
			ads[1]["container"]["nested"].should == ["4", "5"]
		end
    
    it "should parse" do
      mocked_request("<root><item><name><![CDATA[]]></name></item></root>")
      
      @parser = Bliss::Parser.new('mock')

      format = Bliss::Format.new(File.dirname(File.expand_path(__FILE__)) + "/mock/tag_name_required.yml")
      format.reset_constraints_state
      @parser.add_format(format)
      ads = []
      
      @parser.on_tag_close("(root|ads|pepe)/item") { |hash, depth|
        hash['name'].should == {}
        ads << hash
      }
      @parser.parse

      
      ads.size.should == 1
    end

    it "should not eat spaces" do
      mocked_request('
<ads>
  <ad>
    <property_type>Terreno ó Lote</property_type>
    <foo>bar</foo>
  </ad>
</ads>
')
      
      @parser = Bliss::Parser.new('mock')

      
      @parser.on_tag_close("ads/ad") { |hash, depth|
        hash['foo'].should == "bar"
        hash['property_type'].should == "Terreno ó Lote"
        puts hash
      }
      @parser.parse

    end
  end

  context 'when parsing a document with encoding issues' do
    it "should throw an Exception and continue parsing" do
      #xml = <<-EOF
      #EOF

      xml = File.read(File.dirname(File.expand_path(__FILE__)) + "/mock/encoding.xml")

      mocked_request(xml)

      @parser = Bliss::Parser.new('mock', "test.xml")
      res = []
#      exceptions = []

      @parser.on_tag_close("root/ad") { |hash, depth|
        res << true
      }
      puts "\n --PARSING--"
      @parser.parse

      res.count.should == 2 
#      exceptions.count.should == 1
#      exceptions.first.should be_an_instance_of Bliss::EncodingError
    end
 
=begin
    it "should throw an Exception and continue parsing on compressed files" do
      #xml = <<-EOF
      #EOF

      #xml = IO.binread(File.dirname(File.expand_path(__FILE__)) + "/mock/encoding_big.tar.gz")
      xml = IO.binread(File.dirname(File.expand_path(__FILE__)) + "/mock/generic_phones-phones_pdas-active.xml.gz")

      mocked_request(xml, {:compressed => true})

      @parser = Bliss::Parser.new('mock', "test.xml")
      @parser.on_max_unhandled_bytes(200000) {
        puts "Stopped parjsing caused content data for tag was too big!"
        @parser.close
      }

      ads_count = 0
      @parser.on_tag_close("trovit/ad") { |hash, depth|
        #puts "hash: #{hash.inspect}"
        ads_count += 1
        #puts depth.inspect
      }
      @parser.on_error { |error_type, details|
        puts "Error: #{error_type}"
        puts details[:partial_node]
        #puts details[:line]
      }
      begin
        @parser.parse
      #rescue Bliss::EncodingError => err
      #  puts "Encoding error!"
      end
      puts "ADS: #{ads_count}"
    end
=end
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
