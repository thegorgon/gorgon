module ApplicationHelper  
  def set_namespace(value)
    @page_namespace = value
  end

  def page_namespace
    @page_namespace
  end
  
  def hide_header!
    @hide_header = true
  end
  
  def show_header?
    !@hide_header === true
  end
  
  def show_header!
    @hide_header = false
  end

  def page_classes
    names = @page_namespace.to_s.split("_")
    names.pop
    names.join(" ")
  end

  def page_title
    default = "the gorgon lab - rants and ravings from the mind of jesse reiss"
    if @page_title
      @page_title
    elsif @post && @post.respond_to?(:to_tumblr)
      "#{remove_tags(@post.to_tumblr.title)} - #{default}"
    else
      default
    end
  end

  def page_keywords
    keywords = ["jesse reiss", "the gorgon lab", "gorgon", "technology", "entrepreneurship", "blog"]
    keywords += @page_keywords if @page_keywords
    keywords += @post.to_tumblr.tags if @post && @post.respond_to?(:to_tumblr)
    keywords.uniq.join(", ")
  end

  def page_description
    if @page_description
      @page_description
    elsif @post && @post.respond_to?(:to_tumblr)
      "#{(truncate_string(remove_tags(@post.to_tumblr.body), 200).strip)}..."
    else
      "the gorgon lab is the personal website and blog of jesse reiss. topics include technology, entrepreneurship, food, philosophy, and san francsico."
    end
  end
end