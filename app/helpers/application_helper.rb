module ApplicationHelper
  def typekit_tag(id)
    "<script type=\"text/javascript\" src=\"http://use.typekit.com/#{id}.js?v=#{Time.now.to_i}\"></script>
     <script type=\"text/javascript\">try{Typekit.load();}catch(e){}</script>".html_safe
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
    elsif @post && @post.respond_to?(:title)
      "#{@post.title} - #{default}"
    else
      default
    end
  end
  
  def page_keywords
    keywords = ["jesse reiss", "the gorgon lab", "gorgon", "technology", "entrepreneurship", "blog"]
    keywords += @page_keywords if @page_keywords
    keywords += @post.tags if @post && @post.respond_to?(:tags)
    keywords.uniq.join(", ")
  end
  
  def page_description
    if @page_description
      @page_description
    elsif @post && @post.respond_to?(:body)
      "#{truncate_string(remove_tags(@post.body), 200).strip}..."
    else
      "the gorgon lab is the personal website and blog  of jesse reiss. topics include technology, entrepreneurship, food, philosophy, and san francsico."
    end
  end
  
  def seo_tags
    [ meta_name("keywords", page_keywords),
      meta_name("description", page_description)].join("\n").html_safe
  end
  
  def iphone_meta_tags
    meta_name("viewport", "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no")
  end
  
  def open_graph_tags
    tags = []
    tags << meta_property("og:image", "http://www.thegorgonlab.com/images/logos/me202x75.png")
    tags << meta_property("og:title", page_title)
    tags << meta_property("og:description", page_description)
    tags << meta_property("og:url", "#{request.url}")
    tags << meta_property("og:site_name", "the gorgon lab")
    tags.join("\n").html_safe
  end
end
