require 'rubygems'
require 'lib/hash_extension'

hash = {'ads' => {'pictures' => {'picture' => [{'picture_url' => {}, 'picture_title' => {}}]}}}

depth = ['ads', 'pictures', 'picture', 'picture_url']

current = hash.pair_at_chain(depth)
value_at = hash.value_at_chain(depth)

puts current.inspect
puts value_at.inspect

if value_at.is_a? NilClass
  current['picture_url'] = {}
elsif value_at.is_a? Hash
  current['picture_url'] = [current['picture_url']]
end

puts hash.inspect
