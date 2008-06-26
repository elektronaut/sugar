# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080625213006) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "position",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discussions", :force => true do |t|
    t.string   "title"
    t.boolean  "sticky",                       :default => false, :null => false
    t.boolean  "closed",                       :default => false, :null => false
    t.integer  "poster_id",      :limit => 11
    t.integer  "last_poster_id", :limit => 11
    t.integer  "category_id",    :limit => 11
    t.integer  "posts_count",    :limit => 11, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_post_at"
  end

  add_index "discussions", ["poster_id"], :name => "discussion_id_index"
  add_index "discussions", ["category_id"], :name => "category_id_index"
  add_index "discussions", ["created_at"], :name => "created_at_index"
  add_index "discussions", ["created_at"], :name => "last_post_at_index"

  create_table "posts", :force => true do |t|
    t.text     "body"
    t.datetime "edited_at"
    t.integer  "user_id",       :limit => 11
    t.integer  "discussion_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["user_id"], :name => "user_id_index"
  add_index "posts", ["discussion_id"], :name => "discussion_id_index"
  add_index "posts", ["created_at"], :name => "created_at_index"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "realname"
    t.string   "email"
    t.string   "hashed_password"
    t.text     "description"
    t.boolean  "banned",                          :default => false, :null => false
    t.boolean  "activated",                       :default => false, :null => false
    t.boolean  "admin",                           :default => false, :null => false
    t.datetime "last_active"
    t.integer  "posts_count",       :limit => 11, :default => 0
    t.integer  "discussions_count", :limit => 11, :default => 0
    t.integer  "inviter_id",        :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["username"], :name => "username_index"

end
