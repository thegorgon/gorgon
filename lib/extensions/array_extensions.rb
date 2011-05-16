module EnumerableExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
  end
  
  module InstanceMethods
    def hash_by
      hash = {}
      each { |p| hash[yield(p)] = p }
      hash
    end
  end
  
  module ClassMethods
  end  
end


Enumerable.send(:include, EnumerableExtensions)