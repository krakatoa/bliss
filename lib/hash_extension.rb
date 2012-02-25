class Hash
  def value_at_chain(chain)
    current = self
    chain.each do |key|
      if current.has_key? key
        current = current[key]
      else
        current = nil
        break
      end
    end
    return current
  end

  def pair_at_chain(chain)
    chain.pop
    return self.value_at_chain(chain)
  end
end
