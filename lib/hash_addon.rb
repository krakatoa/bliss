class Hash
  def value_at_chain(chain)
    current = self
    chain.each do |key|
      puts current.inspect
      if current.is_a? Hash and current.has_key? key
        current = current[key]
        if current.is_a? Array
          current = current.last
        end
      #elsif current.is_a? Array
      #  current = current.last
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
end
