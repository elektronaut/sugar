# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150801174029) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "avatars", force: :cascade do |t|
    t.string   "content_hash"
    t.string   "content_type"
    t.integer  "content_length"
    t.string   "filename"
    t.string   "colorspace"
    t.integer  "real_width"
    t.integer  "real_height"
    t.integer  "crop_width"
    t.integer  "crop_height"
    t.integer  "crop_start_x"
    t.integer  "crop_start_y"
    t.integer  "crop_gravity_x"
    t.integer  "crop_gravity_y"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversation_relationships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "conversation_id"
    t.boolean  "notifications",   default: true,  null: false
    t.boolean  "new_posts",       default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "conversation_relationships", ["conversation_id"], name: "index_conversation_relationships_on_conversation_id", using: :btree
  add_index "conversation_relationships", ["user_id"], name: "index_conversation_relationships_on_user_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discussion_relationships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "discussion_id"
    t.boolean "participated",  default: false, null: false
    t.boolean "following",     default: true,  null: false
    t.boolean "favorite",      default: false, null: false
    t.boolean "trusted",       default: false, null: false
    t.boolean "hidden",        default: false, null: false
  end

  add_index "discussion_relationships", ["discussion_id"], name: "index_discussion_relationships_on_discussion_id", using: :btree
  add_index "discussion_relationships", ["favorite"], name: "index_discussion_relationships_on_favorite", using: :btree
  add_index "discussion_relationships", ["following"], name: "index_discussion_relationships_on_following", using: :btree
  add_index "discussion_relationships", ["hidden"], name: "index_discussion_relationships_on_hidden", using: :btree
  add_index "discussion_relationships", ["participated"], name: "index_discussion_relationships_on_participated", using: :btree
  add_index "discussion_relationships", ["trusted"], name: "index_discussion_relationships_on_trusted", using: :btree
  add_index "discussion_relationships", ["user_id"], name: "index_discussion_relationships_on_user_id", using: :btree

  create_table "exchange_views", force: :cascade do |t|
    t.integer "user_id"
    t.integer "exchange_id"
    t.integer "post_id"
    t.integer "post_index",  default: 0, null: false
  end

  add_index "exchange_views", ["exchange_id"], name: "discussion_id_index", using: :btree
  add_index "exchange_views", ["post_id"], name: "post_id_index", using: :btree
  add_index "exchange_views", ["user_id", "exchange_id"], name: "user_id_discussion_id_index", unique: true, using: :btree
  add_index "exchange_views", ["user_id"], name: "user_id_index", using: :btree

  create_table "exchanges", force: :cascade do |t|
    t.string   "title"
    t.boolean  "sticky",                     default: false, null: false
    t.boolean  "closed",                     default: false, null: false
    t.boolean  "nsfw",                       default: false, null: false
    t.boolean  "trusted",                    default: false, null: false
    t.integer  "poster_id"
    t.integer  "last_poster_id"
    t.integer  "closer_id"
    t.integer  "posts_count",                default: 0,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_post_at"
    t.string   "type",           limit: 100
  end

  add_index "exchanges", ["created_at"], name: "created_at_index", using: :btree
  add_index "exchanges", ["last_post_at"], name: "last_post_at_index", using: :btree
  add_index "exchanges", ["poster_id"], name: "poster_id_index", using: :btree
  add_index "exchanges", ["sticky", "last_post_at"], name: "index_exchanges_on_sticky_and_last_post_at", using: :btree
  add_index "exchanges", ["sticky"], name: "sticky_index", using: :btree
  add_index "exchanges", ["trusted"], name: "trusted_index", using: :btree
  add_index "exchanges", ["type"], name: "index_exchanges_on_type", using: :btree

  create_table "invites", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "token"
    t.text     "message"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.string   "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                                  null: false
    t.string   "uid",                                   null: false
    t.string   "secret",                                null: false
    t.string   "redirect_uri",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type",   limit: 100
    t.string   "scopes",                   default: "", null: false
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree

  create_table "password_reset_tokens", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "password_reset_tokens", ["user_id"], name: "index_password_reset_tokens_on_user_id", using: :btree

  create_table "post_images", force: :cascade do |t|
    t.string   "content_hash"
    t.string   "content_type"
    t.integer  "content_length"
    t.string   "filename"
    t.string   "colorspace"
    t.integer  "real_width"
    t.integer  "real_height"
    t.integer  "crop_width"
    t.integer  "crop_height"
    t.integer  "crop_start_x"
    t.integer  "crop_start_y"
    t.integer  "crop_gravity_x"
    t.integer  "crop_gravity_y"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "original_url",   limit: 4096
  end

  add_index "post_images", ["id", "content_hash"], name: "index_post_images_on_id_and_content_hash", unique: true, using: :btree
  add_index "post_images", ["original_url"], name: "index_post_images_on_original_url", using: :btree

  create_table "posts", force: :cascade do |t|
    t.text     "body"
    t.text     "body_html"
    t.integer  "user_id"
    t.integer  "exchange_id"
    t.boolean  "trusted",      default: false,      null: false
    t.datetime "edited_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "conversation", default: false,      null: false
    t.string   "format",       default: "markdown", null: false
  end

  add_index "posts", ["conversation"], name: "index_posts_on_conversation", using: :btree
  add_index "posts", ["created_at"], name: "index_posts_on_created_at", using: :btree
  add_index "posts", ["exchange_id", "created_at"], name: "index_posts_on_exchange_id_and_created_at", using: :btree
  add_index "posts", ["exchange_id"], name: "index_posts_on_exchange_id", using: :btree
  add_index "posts", ["trusted"], name: "index_posts_on_trusted", using: :btree
  add_index "posts", ["user_id", "conversation"], name: "index_posts_on_user_id_and_conversation", using: :btree
  add_index "posts", ["user_id", "created_at"], name: "index_posts_on_user_id_and_created_at", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",              limit: 100
    t.string   "realname"
    t.string   "email"
    t.string   "hashed_password"
    t.string   "location"
    t.string   "gamertag"
    t.string   "stylesheet_url"
    t.text     "description"
    t.boolean  "banned",                            default: false, null: false
    t.boolean  "admin",                             default: false, null: false
    t.boolean  "trusted",                           default: false, null: false
    t.boolean  "user_admin",                        default: false, null: false
    t.boolean  "moderator",                         default: false, null: false
    t.boolean  "notify_on_message",                 default: true,  null: false
    t.datetime "last_active"
    t.date     "birthday"
    t.integer  "posts_count",                       default: 0,     null: false
    t.integer  "inviter_id"
    t.string   "msn"
    t.string   "gtalk"
    t.string   "aim"
    t.string   "twitter"
    t.string   "flickr"
    t.string   "last_fm"
    t.string   "website"
    t.string   "openid_url"
    t.float    "longitude"
    t.float    "latitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "available_invites",                 default: 0,     null: false
    t.string   "facebook_uid"
    t.integer  "participated_count",                default: 0,     null: false
    t.integer  "favorites_count",                   default: 0,     null: false
    t.integer  "following_count",                   default: 0,     null: false
    t.string   "time_zone"
    t.datetime "banned_until"
    t.string   "mobile_stylesheet_url"
    t.string   "theme"
    t.string   "mobile_theme"
    t.string   "instagram"
    t.string   "persistence_token"
    t.integer  "public_posts_count",                default: 0,     null: false
    t.integer  "hidden_count",                      default: 0,     null: false
    t.string   "preferred_format"
    t.string   "sony"
    t.integer  "avatar_id"
    t.text     "previous_usernames"
    t.string   "nintendo"
    t.string   "steam"
    t.string   "battlenet"
  end

  add_index "users", ["last_active"], name: "last_active_index", using: :btree
  add_index "users", ["username"], name: "username_index", using: :btree

end
