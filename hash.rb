#require 'rubygems'
require './lib/hash_extension'

def start_element(hash, depth)
  current = hash.pair_at_chain(depth)
  value_at = hash.value_at_chain(depth)
  if current.is_a? Hash
    if value_at.is_a? NilClass
      puts 'nil'
      current[depth.last] = {}
    elsif value_at.is_a? Hash
      puts 'hash'
      current[depth.last] = [current[depth.last], {}]
      current = hash.pair_at_chain(depth)
    end
  elsif current.is_a? Array
  end
end

hash = {'ads' => {'pictures' => {}}}
depth = ['ads', 'pictures', 'picture']
puts "Hash: #{hash.inspect}"
puts "Depth: #{depth.inspect}"
start_element(hash, depth)
puts "#{hash.inspect}"
#puts hash.pair_at_chain(depth).inspect
#puts hash.value_at_chain(depth).inspect
puts "---\n"
#=> pair_at_chain   == {}
#=> value_at_chain  == nil

hash = {'ads' => {'pictures' => {'picture' => {}}}}
depth = ['ads', 'pictures', 'picture']
puts "Hash: #{hash.inspect}"
puts "Depth: #{depth.inspect}"
puts hash.pair_at_chain(depth).inspect
puts hash.value_at_chain(depth).inspect
puts "---\n"
#=> pair_at_chain   == {'picture' => {}}
#=> value_at_chain  == {}

hash = {'ads' => {'pictures' => {'picture' => [{'picture_url' => {}}, {}]}}}
depth = ['ads', 'pictures', 'picture']
puts "Hash: #{hash.inspect}"
puts "Depth: #{depth.inspect}"
puts hash.pair_at_chain(depth).inspect
puts hash.value_at_chain(depth).inspect
puts "---\n"
#=> pair_at_chain   == {'picture' => {}}
#=> value_at_chain  == {}

hash = {'ads' => {'pictures' => {'picture' => [{'picture_url' => {}}, {}]}}}
depth = ['ads', 'pictures', 'picture']
puts "Hash: #{hash.inspect}"
puts "Depth: #{depth.inspect}"
puts hash.pair_at_chain(depth).inspect
puts hash.value_at_chain(depth).inspect
puts "---\n"
#=> pair_at_chain   == {'picture' => {}}
#=> value_at_chain  == {}

hash = {'ads' => {'pictures' => {'picture' => [{'picture_url' => {}}, {}]}}}
depth = ['ads', 'pictures', 'picture', 'picture_url']
puts "Hash: #{hash.inspect}"
puts "Depth: #{depth.inspect}"
puts hash.pair_at_chain(depth).inspect
puts hash.value_at_chain(depth).inspect
puts "---\n"
#=> pair_at_chain   == [{'picture_url' => {}}, {'picture_url' => {}}]
#=> value_at_chain  == {}


hash = {'ads' => {'pictures' => {'picture' => [{'picture_url' => {}}, {'picture_url' => {}}]}}}
depth = ['ads', 'pictures', 'picture', 'picture_url']
puts "Hash: #{hash.inspect}"
puts "Depth: #{depth.inspect}"
puts hash.pair_at_chain(depth).inspect
puts hash.value_at_chain(depth).inspect
puts "---\n"
#=> pair_at_chain   == [{'picture_url' => {}}, {'picture_url' => {}}]
#=> value_at_chain  == {}

