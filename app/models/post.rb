class Post < ActiveRecord::Base  
  has_many :comments, :primary_key => :tumblr_id
  @@per_page = 10
  cattr_reader :per_page
  
  def self.from_tumblr(params={})
    items = Tumblr::Item.paginate(:page => params[:page], :per_page => params[:per_page])
    items.collect do |item|
      object = find_or_initialize_by_tumblr_id(item.id)
      object.from_tumblr(item)
      object
    end
  end
  
  def self.refresh!(params={})
    from_tumblr(params).map { |i| i.save! }
  end
  
  def self.by_slug(slug)
    @post = Post.where(:slug => slug).first
    raise ActiveRecord::RecordNotFound unless @post.present?
    @post
  end
  
  def refresh!
    tumblr = Tumblr::Item.find(tumblr_id)
    from_tumblr(tumblr)
    save!
  end
  
  def from_tumblr(tumblr)
    self.slug = tumblr.slug
    self.tumblr_id = tumblr.id
    self.xml = tumblr.xml
    self.tumblr_type = tumblr.type
    self.created_at = tumblr.date
  end
  
  def to_tumblr
    unless @tumblr
      klass = "Tumblr::#{tumblr_type.classify}".constantize
      @tumblr = klass.new
      @tumblr.send(:parse_xml_node, Nokogiri::XML.parse(xml))
    end
    @tumblr
  end
  
  def to_param
    slug
  end
end