$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'

require 'bundler'
Bundler.require(:default, :development)

Dir["#{File.dirname(__FILE__)}/../lib/**/*.rb"].each {|f| require f}

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end

def mocked_request(content, opts={})
  # possible opts content
  # {:compressed => true}
  opts[:compressed] ||= false

  Addressable::URI.any_instance.stub(:validate) { nil }
  Addressable::URI.any_instance.stub(:port) { 80 }
  Addressable::URI.any_instance.stub(:host) { 'mock' }

  http_response_header = mock(EM::HttpResponseHeader)
  http_response_header.stub(:compressed?) { opts[:compressed] }
  http_response_header.should_receive(:[]).with('CONTENT_DISPOSITION')#.and_return("xml")
  http_response_header.should_receive(:[]).with("CONTENT_TYPE")#.and_return("application/xml")

  http_client = mock(EM::HttpClient)
  http_client.stub(:response_header) { http_response_header }
  http_client.stub(:headers).and_yield {}
  http_client.stub(:stream).and_yield(content) { }
  http_client.stub(:errback).and_yield {}
  http_client.stub(:callback).and_yield {}
  
  http_connection = mock(EM::HttpConnection)
  http_connection.stub(:get) { http_client }
  
  EM::HttpRequest.should_receive(:new).with('mock').and_return(http_connection)
end
