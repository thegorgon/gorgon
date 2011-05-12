module ApplicationHelper
  def typekit_tag(id)
    "<script type=\"text/javascript\" src=\"http://use.typekit.com/#{id}.js?v=#{Time.now.to_i}\"></script>
     <script type=\"text/javascript\">try{Typekit.load();}catch(e){}</script>".html_safe
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
    result
  end

  def blog_post_preview(post)
    body = post.body
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
end
