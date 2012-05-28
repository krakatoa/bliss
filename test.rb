require 'rubygems'
require 'bliss'

p = Bliss::Parser.new('', 'output.xml')
p.wait_tag_close('ad')
#p.on_max_unhandled_bytes(20000) {
#  puts 'Reached Max Unhandled Bytes'
#  p.close
#}

@count = 0
@makes = 0

f = Bliss::Format.new

p.add_format(f)

p.on_tag_close('ad') { |hash, depth|
  if hash.has_key?('make')
    @makes += 1
  end
  @count += 1

  if @count == 600
    p.close
  end
}

=begin
p.on_tag_close('ad') { |hash|
  count += 1

  dict = {"make"=>"name"}
  only_in_dict = false
  hash = hash.inject({}) { |h,v| key = dict.invert[v[0]]; key ||= v[0] unless only_in_dict; h[key] = v[1] if key; h }
  
  #puts hash.keys.inspect
  if count == 100
    p.close
  end
}
=end

begin
  p.parse
rescue Bliss::EncodingError
  puts "Encoding Error!"
end

puts @count
puts @makes

puts p.formats_details.inspect
