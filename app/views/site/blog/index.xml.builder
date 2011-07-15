xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "the gorgon lab"
    xml.description "the gorgon lab is the personal website and blog  of jesse reiss. topics include technology, entrepreneurship, food, philosophy, and san francsico."
    xml.link blog_url

     @posts.each do |post|
      tumblr = post.to_tumblr
      xml.item do
        xml.title tumblr.title.downcase.html_safe
        xml.description tumblr.body.html_safe
        xml.pubDate tumblr.date.to_s(:rfc822)
        xml.link blog_post_url(post)
      end
    end
  end
end