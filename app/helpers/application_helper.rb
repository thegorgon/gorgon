module ApplicationHelper
  def typekit_tag(id)
    "<script type=\"text/javascript\" src=\"http://use.typekit.com/#{id}.js?v=#{Time.now.to_i}\"></script>
     <script type=\"text/javascript\">try{Typekit.load();}catch(e){}</script>".html_safe
  end
  
  def at_anywhere_tag(key)
    "<script type=\"text/javascript\" src=\"http://platform.twitter.com/anywhere.js?id=#{key}&v=1\"></script>".html_safe
  end
  
  def param_path(path, add)
    keep = params.symbolize_keys.except(:action, :controller)
    send("#{path}_path", keep.merge(add))
  end
  
  def button_tag(options={}, &block)
    options[:type] ||= 'submit'
    button = "<button"
    options.each do |k, v|
      button << " #{k}=\"#{v}\""
    end
    button << "><div class=\"btntxt\">"
    button << capture(&block) if block
    button << "</div></button>"
    button.html_safe
  end
  
  def analytics_tag(account_id)
    content_tag(:script, :type => Mime::JS) do
      "var _gaq = _gaq || [];
      _gaq.push(['_setAccount', '#{account_id}']);
      _gaq.push(['_setDomainName', '.thegorgonlab.com']);
      _gaq.push(['_trackPageview']);

      (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();"
    end
  end
  
  def link_to_with_current(*args)
    options = args.extract_options!
    current_class = options.delete(:current_class) || "active"
    options[:class] ||= ""
    options[:class] << " " if options[:class].present?
    options[:class] << current_class if request.path == args.last
    args << options
    link_to *args
  end

  def truncate_string(string, length)
    words = string.split(' ')
    result = ""
    words.each do |word|
      result << " #{word}"
      break if result.length >= length
    end
    result.gsub!(/[^a-zA-Z0-9]$/, '')
    result
  end

  def remove_tags(text)
    text.gsub(/\<[^\>]+\>(.*?)(<\/p\>)?/, '\1')
  end

  def blog_post_preview(post)
    body = post.body.to_s
    preview = ""
    body.scan(/\<p\>(.+?)<\/p\>/) do |m|
      if preview.length + m[0].to_s.length > 500
        preview << "<p>#{truncate_string(m[0], 500 - preview.length)}...</p>"
        break
      else
        preview << "<p>#{m[0]}</p>"
      end
    end
    preview.html_safe
  end
  
  def first_or_last(i, length)
    length = length.count if length.respond_to?(:count)
    if i == length - 1
      'last'
    elsif i == 0
      'first'
    end
  end
  
  def meta_property(property, content)
    tag(:meta, :property => property, :content => content)
  end
  
  def meta_name(name, content)
    tag(:meta, :name => name, :content => content)
  end
  
  def page_title
    default = "the gorgon lab - rants and ravings from the mind of jesse reiss"
    if @page_title
      @page_title
    elsif @post && @post.respond_to?(:to_tumblr)
      "#{remove_tags(@post.to_tumblr.title)} - #{default}".html_safe
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
      "#{(truncate_string(remove_tags(@post.to_tumblr.body), 200).strip)}...".html_safe
    else
      "the gorgon lab is the personal website and blog of jesse reiss. topics include technology, entrepreneurship, food, philosophy, and san francsico."
    end
  end
  
  def seo_tags
    [ meta_name("keywords", page_keywords),
      meta_name("description", page_description)].join("\n").html_safe
  end
  
  def iphone_meta_tags
    meta_name("viewport", "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no")
  end
  
  def img_link_to(src, url, options={})
    link_to image_tag(src, options.slice(:size, :width, :height, :border, :alt)), url, options.except(:size, :width, :height, :border, :alt)
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
    tags.join("\n").html_safe
  end
  
  # Create a named haml tag to wrap IE conditional around a block
  # http://paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither
  def ie_tag(name=:body, attrs={}, &block)
    attrs.symbolize_keys!
    haml_concat("<!--[if lt IE 7]> #{ tag(name, add_class('ie6', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 7]>    #{ tag(name, add_class('ie7', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 8]>    #{ tag(name, add_class('ie8', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if gt IE 8]><!-->".html_safe)
    haml_tag name, attrs do
      haml_concat("<!--<![endif]-->".html_safe)
      block.call
    end
  end

  def ie_html(attrs={}, &block)
    ie_tag(:html, attrs, &block)
  end

  def ie_body(attrs={}, &block)
    ie_tag(:body, attrs, &block)
  end
  
  private
  
  def add_class(name, attrs)
    classes = attrs[:class] || ''
    classes.strip!
    classes = ' ' + classes if !classes.blank?
    classes = name + classes
    attrs.merge(:class => classes)
  end  
end
