module MetaHelper
  def set_title(value)
    @page_title = value
  end
  
  def prepend_title(value)
    @page_title ||= ""
    @page_title = @page_title.length > 0 ? "#{value} - #{@page_title}" : value
  end
  
  def append_title(value)
    @page_title ||= ""
    @page_title << @page_title.length > 0 ? "- #{value}" : value
  end

  def page_title
    @page_title
  end
  
  def append_keywords(*kws)
    kws = kws.first if kws.length == 1 && kws.first.kind_of?(Array)
    @page_keywords = (@page_keywords || []) + kws
  end
  
  def prepend_keywords(*kws)
    kws = kws.first if kws.length == 1 && kws.first.kind_of?(Array)
    @page_keywords = kws + (@page_keywords || [])
  end

  def set_keywords(*kws)
    kws = kws.first if kws.length == 1 && kws.first.kind_of?(Array)
    @page_keywords = kws
  end

  def page_keywords
    (@page_keywords || []).uniq.join(', ')
  end
  
  def set_description(value)
    @page_description = value
  end
  
  def page_description
    @page_description
  end
  
  def set_namespace(value)
    @page_namespace = value
  end

  def page_namespace
    @page_namespace
  end

  def page_classes
    names = @page_namespace.to_s.split("_")
    names.pop
    names.join(" ")
  end
  
  def meta_property(property, content)
    tag(:meta, :property => property, :content => content)
  end

  def meta_name(name, content)
    tag(:meta, :name => name, :content => content)
  end
  
  def favicon_link_tag(source='/favicon.ico', options={})
    tag('link', {
      :rel  => 'shortcut icon',
      :type => 'image/vnd.microsoft.icon',
      :href => compute_public_path(source),
    }.merge(options.symbolize_keys))
  end
  
  def auto_discovery_link_tag(type = "application/rss+xml", url = "/index.xml", tag_options = {})
    tag(
      "link",
      "rel"   => tag_options[:rel] || "alternate",
      "type"  => tag_options[:type],
      "title" => tag_options[:title] || type.to_s.upcase,
      "href"  => url
    )
  end
  
  def seo_tags
    [ meta_name("keywords", page_keywords),
      meta_name("description", page_description)].join("\n")
  end

  def iphone_meta_tags
    meta_name("viewport", "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no")
  end
  
  def open_graph_tags
    tags = []
    tags << meta_property("og:image", "http://www.thegorgonlab.com/images/logos/me300x300.png")
    tags << meta_property("og:type", "blog")
    tags << meta_property("og:title", page_title)
    tags << meta_property("og:description", page_description)
    tags << meta_property("og:url", "#{request.url}")
    tags << meta_property("fb:admins", "100000043724571")
    tags << meta_property("og:site_name", "the gorgon lab")
    tags.join("\n")
  end
end