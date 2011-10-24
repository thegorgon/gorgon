require "redis/set"
require "redis/value"
require "redis/list"
require 'tumblr'
require 'tumblr/item'
require 'json'
require 'will_paginate/collection'
require 'digest/sha1'

class Blog
  STORAGE_KEY = "gorgon:blog:entries"
  PAGE_SIZE = 3
  attr_accessor :slug, :tumblr_id, :xml, :tumblr_type, :created_at
  
  def self.clear!
    Redis::Objects.redis.keys("#{STORAGE_KEY}:*").each { |key| Redis::Objects.redis.del(key) }
    index.clear
  end
  
  def self.refresh!(options={})
    clear!
    
    page = options[:min] || 1
    per_page = options[:per_page] || 100
    max_page = options[:max]
    
    loop do
      items = Tumblr::Item.paginate(:page => page, :per_page => per_page)
      if items && items.success?
        page = items.next_page
        items.each do |item|
          index << item.slug
          entry = Blog.new.from_tumblr(item)
          entry.tumblr_id = item.id
          entry.commit
        end
        break if page.nil? || (max_page && page > max_page)
      end
    end
  end
  
  def self.all(slugs=nil)
    slugs ||= index
    entries = slugs.collect { |slug| find(slug) }
    entries.compact!
    entries
  end
  
  def self.page(n)
    n = [1, n.to_i].max
    WillPaginate::Collection.create(n, PAGE_SIZE, index.count) do |pager|
      pager.replace Blog.all(index[pager.offset, pager.per_page]).to_a
    end
  end
  
  def self.index
    @index ||= Redis::List.new(STORAGE_KEY)
  end
    
  def self.find(slug)
    value = Redis::Value.new("#{STORAGE_KEY}:#{slug}")
    unserialize(value.value)
  end
  
  def self.serialize(object)
    {
      "slug" => object.slug,
      "tumblr_id" => object.tumblr_id,
      "xml" => object.xml,
      "tumblr_type" => object.tumblr_type,
      "created_at" => object.created_at
    }.to_json
  end
  
  def self.unserialize(object)
    params = JSON.parse(object) rescue nil
    if params.present?
      object = Blog.new
      ["slug", "tumblr_id", "xml", "tumblr_type", "created_at"].each do |attribute|
        object.send("#{attribute}=", params[attribute])
      end
      object
    end
  end
  
  def self.tags
    Redis::Set.new("#{STORAGE_KEY}:tags")
  end

  def self.tagged_with(tag)
    Redis::Set.new("#{STORAGE_KEY}:tags:#{tag.downcase.underscore}")
  end
  
  def refresh!
    tumblr = Tumblr::Item.find(tumblr_id)
    from_tumblr(tumblr)
    commit
  end
  
  def from_tumblr(tumblr)
    self.slug = tumblr.slug
    self.tumblr_id = tumblr.id
    self.xml = tumblr.xml
    self.tumblr_type = tumblr.type
    self.created_at = tumblr.date
    self
  end
  
  def etag
    Digest::SHA1.hexdigest(xml)
  end
  
  def tags
    to_tumblr.tags
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
  
  def storage
    @value ||= Redis::Value.new("#{STORAGE_KEY}:#{slug}")
  end
  
  def serialize
    self.class.serialize(self)
  end
  
  def commit
    storage.value = self.serialize
    tags.each do |tag|
      Redis::Set.new("#{STORAGE_KEY}:tags") << tag
      Redis::Set.new("#{STORAGE_KEY}:tags:#{tag.downcase.underscore}") << slug
    end
  end
  
  def respond_to?(method)
    if to_tumblr.respond_to?(method)
      true
    else
      super(method)
    end
  end
  
  def method_missing(method, *args, &block)
    if to_tumblr.respond_to?(method)
      to_tumblr.send(method, *args, &block)
    else
      super(method, *args, &block)
    end
  end
end