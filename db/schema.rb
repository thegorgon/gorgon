# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110513063528) do

  create_table "comments", :force => true do |t|
    t.string   "post_id",                    :null => false
    t.string   "author",     :default => "", :null => false
    t.string   "url",        :default => "", :null => false
    t.text     "body",                       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["post_id"], :name => "index_comments_on_post_id"

  create_table "posts", :force => true do |t|
    t.string   "slug",        :null => false
    t.string   "tumblr_id",   :null => false
    t.string   "tumblr_type", :null => false
    t.text     "xml",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["created_at", "slug"], :name => "index_posts_on_created_at_and_slug"
  add_index "posts", ["tumblr_id"], :name => "index_posts_on_tumblr_id"

end
