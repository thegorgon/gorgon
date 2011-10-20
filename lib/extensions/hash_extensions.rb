module HashExtensions
  def slice(*keys)
    allowed = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
    hash = {}
    allowed.each { |k| hash[k] = self[k] if has_key?(k) }
    hash
  end
  
  def slice!(*keys)
    replace(slice(*keys))
  end
  
  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end
    
  def except(*keys)
    dup.except!(*keys)
  end
  
  def symbolize_keys
    dup.symbolize_keys!
  end
  
  def symbolize_keys!
    keys.each do |key|
      self[(key.to_sym rescue key) || key] = delete(key)
    end
    self
  end
  
  def stringify_keys!
    keys.each do |key|
      self[key.to_s] = delete(key)
    end
    self
  end
  
  def stringify_keys
    dup.stringify_keys!
  end
end

Hash.send(:include, HashExtensions)