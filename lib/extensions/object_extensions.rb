#https://github.com/rails/rails/blob/bca510cec23aff4c147f2ab5c30de930f120d84b/activesupport/lib/active_support/core_ext/object/try.rb#L25

class Object
  def try(method, *args, &block)
    send(method, *args, &block)
  end
  remove_method :try
  alias_method :try, :__send__
  
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
  
  def present?
    !blank?
  end
end

class NilClass #:nodoc:
  def try(*args)
    nil
  end
end
