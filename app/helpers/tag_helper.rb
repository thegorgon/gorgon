module TagHelper
  def mail_to(email_address, name = nil, html_options = {})
    email_address = html_escape(email_address)

    html_options = html_options.stringify_keys
    encode = html_options.delete("encode").to_s
    cc, bcc, subject, body = html_options.delete("cc"), html_options.delete("bcc"), html_options.delete("subject"), html_options.delete("body")

    email_address_obfuscated = email_address.dup
    email_address_obfuscated.gsub!(/@/, html_options.delete("replace_at")) if html_options.has_key?("replace_at")
    email_address_obfuscated.gsub!(/\./, html_options.delete("replace_dot")) if html_options.has_key?("replace_dot")

    string = ''

    if encode == "javascript"
      html   = content_tag("a", name || email_address_obfuscated, html_options.merge("href" => "mailto:#{email_address}"))
      "document.write('#{html}');".each_byte do |c|
        string << sprintf("%%%x", c)
      end
      
      "<script type=\"application/javascript\">eval(decodeURIComponent('#{string}'))</script>"
    elsif encode == "hex"
      email_address_encoded = ''
      email_address_obfuscated.each_byte do |c|
        email_address_encoded << sprintf("&#%d;", c)
      end

      protocol = 'mailto:'
      protocol.each_byte { |c| string << sprintf("&#%d;", c) }

      email_address.each_byte do |c|
        char = c.chr
        string << (char =~ /\w/ ? sprintf("%%%x", c) : char)
      end
      content_tag "a", name || email_address_encoded, html_options.merge("href" => "#{string}")
    else
      content_tag "a", name || email_address_obfuscated, html_options.merge("href" => "mailto:#{email_address}")
    end
  end
  
  def link_to(text, url, options={})
    content_tag("a", text, options.merge!(:href => url))
  end
  
  def img_link_to(src, url, options={})
    link_to image_tag(src, options.slice(:size, :width, :height, :border, :alt)), url, options.except(:size, :width, :height, :border, :alt)
  end
  
  def link_to_with_current(text, url, options={})
    add_class("current", options) if current_page?(url)
    link_to text, url, options
  end
  
  def current_page?(path)
    request.path_info == path
  end
  
  def button_tag(options={}, &block)
    options[:type] ||= 'submit'
    button = "<button"
    options.each do |k, v|
      button << " #{k}=\"#{v}\""
    end
    button << "><div class=\"btntxt\">"
    haml_concat(button)
    block.call if block
    haml_concat("</div></button>")
  end

  def analytics_tag(account_id)
    content_tag("script", :type => "application/javascript") do
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

  def typekit_tag(id)
    "<script type=\"text/javascript\" src=\"http://use.typekit.com/#{id}.js?v=#{Time.now.to_i}\"></script>
     <script type=\"text/javascript\">try{Typekit.load();}catch(e){}</script>"
  end

  def at_anywhere_tag(key)
    "<script type=\"text/javascript\" src=\"http://platform.twitter.com/anywhere.js?id=#{key}&v=1\"></script>"
  end
  
  # Create a named haml tag to wrap IE conditional around a block
  # http://paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither
  def ie_tag(name=:body, attrs={}, &block)
    attrs.symbolize_keys!
    haml_concat("<!--[if lt IE 7]> #{ tag(name, add_class('ie6', attrs), false) } <![endif]-->")
    haml_concat("<!--[if IE 7]>    #{ tag(name, add_class('ie7', attrs), false) } <![endif]-->")
    haml_concat("<!--[if IE 8]>    #{ tag(name, add_class('ie8', attrs), false) } <![endif]-->")
    haml_concat("<!--[if gt IE 8]><!-->")
    haml_tag name, attrs do
      haml_concat("<!--<![endif]-->")
      block.call
    end
  end

  def ie_html(attrs={}, &block)
    ie_tag(:html, attrs, &block)
  end

  def ie_body(attrs={}, &block)
    ie_tag(:body, attrs, &block)
  end
  
  def first_or_last(index, collection)
    if index == collection.length - 1
      "last"
    elsif index == 0
      "first"
    else
      nil
    end
  end
  
  private
  
  def add_class(name, attrs)
    classes = (attrs[:class] || '').split(' ')
    classes << name
    classes.uniq!
    classes.compact!
    classes = classes.join(' ')
    classes.strip!
    attrs.merge(:class => classes)
  end
end