class BlogPage < Struct.new(:entries, :page, :page_size, :total_count)
  include Enumerable
  
  def total_pages
    (total_count/page_size.to_f).ceil
  end
  
  def last_page?
    page == total_pages
  end
  
  def first_page?
    page == 1
  end
  
  def previous_page
    first_page?? nil : page - 1
  end
  
  def next_page
    last_page?? nil : page + 1
  end
  
  def each
    entries.each do |entry|
      yield(entry)
    end
  end
end