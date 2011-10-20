module MetaHelper
  def page_title
    @page_title || ""
  end

  def page_keywords
    @page_keywords || ""
  end

  def page_description
    @page_descriptions || ""
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