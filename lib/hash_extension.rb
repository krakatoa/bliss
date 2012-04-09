class Hash
  def value_at_chain(chain)
    current = self
    chain.each do |key|
      if current.is_a? Hash and current.has_key? key
        current = current[key]
        if current.is_a? Array
          current = current.last
        end
      else
        current = nil
        break
      end
    end
    return current
  end

  def pair_at_chain(chain)
    chain = chain.dup
    chain.pop
    return self.value_at_chain(chain)
  end

  def recurse_hash(hash, depth)
    hash.each_pair { |k,v|
      if v.is_a? Hash
        depth.push k
        recurse_hash(v, depth)
      else
        puts "#{depth + [k]}: #{v.inspect}"
      end
    }
    depth.pop
  end
end
