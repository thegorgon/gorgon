xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "the gorgon lab"
    xml.description "the gorgon lab is the personal website and blog  of jesse reiss. topics include technology, entrepreneurship, food, philosophy, and san francsico."
    xml.link url('/blog')

     @posts.each do |post|
      tumblr = post.to_tumblr
      xml.item do
        xml.title tumblr.title.downcase
        xml.description tumblr.body
        xml.pubDate tumblr.date.strftime('%a, %d %b %Y %H:%M:%S %z')
        xml.link url("/blog/#{post.to_param}")
      end
    end
  end
end