class Comment < ActiveRecord::Base
  validates :body, :presence => true
  validates :author, :presence => true
  validates :url, :format => URL_REGEX, :if => :url?
  validates :post_id, :presence => true
  
  def url=(value)
    value = "http://#{value}" unless value =~ /^http|https:\/\/.+/
    self[:url] = value
  end
end