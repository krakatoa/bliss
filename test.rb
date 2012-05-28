require 'rubygems'
require 'bliss'

p = Bliss::Parser.new('http://www.topdiffusion.com/flux/topdiffusion_adsdeck.xml')
p.wait_tag_close('ad')
p.max_unhandled_bytes = 20000

@count = 0

f = Bliss::Format.new

p.add_format(f)

#p.on_tag_close { |hash, depth|
  #puts hash.inspect
#  @count += 1
  #puts "Ad ##{@count}"
#}

begin
  p.parse
rescue Bliss::EncodingError
  puts "Encoding Error!"
end

p.formats_details
