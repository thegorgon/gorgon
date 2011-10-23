require 'cgi'

module StringExtensions
  def html_strip
    CGI.unescapeHTML(gsub(%r{</?[^>]+?>}, ''))
  end
  
  def max_length(max, append='')
    if length > max
      truncated = ""
      split(' ').each do |word|
        truncated << "#{word} "
        break if truncated.length > max
      end
      truncated.strip
    else
      self
    end
  end
end

String.send(:include, StringExtensions)