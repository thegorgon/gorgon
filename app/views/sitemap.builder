xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc url('/blog')
    xml.lastmod @posts.first.date.iso8601
    xml.changefreq 'daily'
    xml.priority '0.8'
  end
  @posts.each do |post|
    xml.url do
      xml.loc        url("/blog/#{post.to_param}")
      xml.lastmod    post.date.iso8601
    end
  end
end
