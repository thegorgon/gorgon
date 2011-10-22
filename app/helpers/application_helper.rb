module ApplicationHelper    
  def hide_header!
    @hide_header = true
  end
  
  def show_header?
    !@hide_header === true
  end
  
  def show_header!
    @hide_header = false
  end
end