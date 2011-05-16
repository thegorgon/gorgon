class AddComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :post_id, :null => false
      t.string :author, :null => false, :default => ""
      t.string :url, :null => false, :default => ""
      t.text :body, :null => false, :default => ""
      t.timestamps
    end
    add_index :comments, :post_id
    
    create_table :posts do |t|
      t.string :slug, :null => false
      t.string :tumblr_id, :null => false
      t.string :tumblr_type, :null => false
      t.text :xml, :null => false
      t.timestamps
    end
    
    add_index :posts, [:created_at, :slug]
    add_index :posts, :tumblr_id, :uniq => true
  end

  def self.down
    drop_table :comments
    drop_table :posts
  end
end
