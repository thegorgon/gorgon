class RemoveComments < ActiveRecord::Migration
  def self.up
    drop_table :comments
  end

  def self.down
    create_table "comments", :force => true do |t|
      t.string   "post_id",                    :null => false
      t.string   "author",     :default => "", :null => false
      t.string   "url",        :default => "", :null => false
      t.text     "body",                       :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "comments", ["post_id"], :name => "index_comments_on_post_id"
  end
end
