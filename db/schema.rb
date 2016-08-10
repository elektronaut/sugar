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

ActiveRecord::Schema.define(version: 20160810181227) do

  create_table "avatars", force: :cascade do |t|
    t.string   "content_hash",   limit: 255
    t.string   "content_type",   limit: 255
    t.integer  "content_length", limit: 4
    t.string   "filename",       limit: 255
    t.string   "colorspace",     limit: 255
    t.integer  "real_width",     limit: 4
    t.integer  "real_height",    limit: 4
    t.integer  "crop_width",     limit: 4
    t.integer  "crop_height",    limit: 4
    t.integer  "crop_start_x",   limit: 4
    t.integer  "crop_start_y",   limit: 4
    t.integer  "crop_gravity_x", limit: 4
    t.integer  "crop_gravity_y", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversation_relationships", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.integer  "conversation_id", limit: 4
    t.boolean  "notifications",             default: true,  null: false
    t.boolean  "new_posts",                 default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "conversation_relationships", ["conversation_id"], name: "conversation_id_index", using: :btree
  add_index "conversation_relationships", ["user_id"], name: "user_id_index", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0
    t.integer  "attempts",   limit: 4,     default: 0
    t.text     "handler",    limit: 65535
    t.string   "last_error", limit: 255
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discussion_relationships", force: :cascade do |t|
    t.integer "user_id",       limit: 4
    t.integer "discussion_id", limit: 4
    t.boolean "participated",            default: false, null: false
    t.boolean "following",               default: true,  null: false
    t.boolean "favorite",                default: false, null: false
    t.boolean "trusted",                 default: false, null: false
    t.boolean "hidden",                  default: false, null: false
  end

  add_index "discussion_relationships", ["discussion_id"], name: "discussion_id_index", using: :btree
  add_index "discussion_relationships", ["favorite"], name: "favorite_index", using: :btree
  add_index "discussion_relationships", ["following"], name: "following_index", using: :btree
  add_index "discussion_relationships", ["hidden"], name: "index_discussion_relationships_on_hidden", using: :btree
  add_index "discussion_relationships", ["participated"], name: "participated_index", using: :btree
  add_index "discussion_relationships", ["trusted"], name: "trusted_index", using: :btree
  add_index "discussion_relationships", ["user_id"], name: "user_id_index", using: :btree

  create_table "discussion_views_backup", force: :cascade do |t|
    t.integer "user_id",       limit: 4
    t.integer "discussion_id", limit: 4
    t.integer "post_id",       limit: 4
    t.integer "post_index",    limit: 4, default: 0, null: false
  end

  add_index "discussion_views_backup", ["discussion_id"], name: "discussion_id_index", using: :btree
  add_index "discussion_views_backup", ["post_id"], name: "post_id_index", using: :btree
  add_index "discussion_views_backup", ["user_id"], name: "user_id_index", using: :btree

  create_table "exchange_moderators", force: :cascade do |t|
    t.integer  "exchange_id", limit: 4, null: false
    t.integer  "user_id",     limit: 4, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "exchange_moderators", ["exchange_id"], name: "index_exchange_moderators_on_exchange_id", using: :btree
  add_index "exchange_moderators", ["user_id"], name: "index_exchange_moderators_on_user_id", using: :btree

  create_table "exchange_views", force: :cascade do |t|
    t.integer "user_id",     limit: 4
    t.integer "exchange_id", limit: 4
    t.integer "post_id",     limit: 4
    t.integer "post_index",  limit: 4, default: 0, null: false
  end

  add_index "exchange_views", ["exchange_id"], name: "discussion_id_index", using: :btree
  add_index "exchange_views", ["post_id"], name: "post_id_index", using: :btree
  add_index "exchange_views", ["user_id", "exchange_id"], name: "user_id_discussion_id_index", unique: true, using: :btree
  add_index "exchange_views", ["user_id"], name: "user_id_index", using: :btree

  create_table "exchanges", force: :cascade do |t|
    t.integer  "poster_id",      limit: 4
    t.integer  "last_poster_id", limit: 4
    t.boolean  "closed",                     default: false, null: false
    t.boolean  "sticky",                     default: false, null: false
    t.string   "title",          limit: 255
    t.datetime "created_at"
    t.datetime "last_post_at"
    t.datetime "updated_at"
    t.boolean  "nsfw",                       default: false, null: false
    t.boolean  "trusted",                    default: false, null: false
    t.integer  "posts_count",    limit: 4,   default: 0
    t.integer  "closer_id",      limit: 4
    t.string   "type",           limit: 255
  end

  add_index "exchanges", ["created_at"], name: "created_at_index", using: :btree
  add_index "exchanges", ["last_post_at"], name: "last_post_at_index", using: :btree
  add_index "exchanges", ["poster_id"], name: "poster_id_index", using: :btree
  add_index "exchanges", ["sticky", "last_post_at"], name: "sticky", using: :btree
  add_index "exchanges", ["sticky"], name: "sticky_index", using: :btree
  add_index "exchanges", ["title"], name: "discussions_title_fulltext", type: :fulltext
  add_index "exchanges", ["trusted"], name: "trusted_index", using: :btree
  add_index "exchanges", ["type"], name: "type_index", using: :btree

  create_table "invites", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "email",      limit: 255
    t.string   "token",      limit: 255
    t.text     "message",    limit: 65535
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4,   null: false
    t.integer  "application_id",    limit: 4,   null: false
    t.string   "token",             limit: 255, null: false
    t.integer  "expires_in",        limit: 4,   null: false
    t.string   "redirect_uri",      limit: 255, null: false
    t.datetime "created_at",                    null: false
    t.datetime "revoked_at"
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4
    t.integer  "application_id",    limit: 4,   null: false
    t.string   "token",             limit: 255, null: false
    t.string   "refresh_token",     limit: 255
    t.integer  "expires_in",        limit: 4
    t.datetime "revoked_at"
    t.datetime "created_at",                    null: false
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",         limit: 255,              null: false
    t.string   "uid",          limit: 255,              null: false
    t.string   "secret",       limit: 255,              null: false
    t.string   "redirect_uri", limit: 255,              null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "owner_id",     limit: 4
    t.string   "owner_type",   limit: 255
    t.string   "scopes",       limit: 255, default: "", null: false
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "password_reset_tokens", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "token",      limit: 255
    t.datetime "expires_at"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "password_reset_tokens", ["user_id"], name: "index_password_reset_tokens_on_user_id", using: :btree

  create_table "post_images", force: :cascade do |t|
    t.string   "content_hash",   limit: 255
    t.string   "content_type",   limit: 255
    t.integer  "content_length", limit: 4
    t.string   "filename",       limit: 255
    t.string   "colorspace",     limit: 255
    t.integer  "real_width",     limit: 4
    t.integer  "real_height",    limit: 4
    t.integer  "crop_width",     limit: 4
    t.integer  "crop_height",    limit: 4
    t.integer  "crop_start_x",   limit: 4
    t.integer  "crop_start_y",   limit: 4
    t.integer  "crop_gravity_x", limit: 4
    t.integer  "crop_gravity_y", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "original_url",   limit: 4096
  end

  add_index "post_images", ["id", "content_hash"], name: "index_post_images_on_id_and_content_hash", unique: true, using: :btree
  add_index "post_images", ["original_url"], name: "index_post_images_on_original_url", length: {"original_url"=>250}, using: :btree

  create_table "posts", force: :cascade do |t|
    t.integer  "exchange_id",  limit: 4
    t.integer  "user_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "body",         limit: 65535
    t.string   "format_type",  limit: 255
    t.text     "body_html",    limit: 65535
    t.datetime "edited_at"
    t.boolean  "trusted",                    default: false,      null: false
    t.boolean  "conversation",               default: false,      null: false
    t.string   "format",       limit: 255,   default: "markdown", null: false
  end

  add_index "posts", ["conversation"], name: "type_index", using: :btree
  add_index "posts", ["created_at"], name: "created_at_index", using: :btree
  add_index "posts", ["exchange_id", "created_at"], name: "discussion_id", using: :btree
  add_index "posts", ["exchange_id"], name: "discussion_id_index", using: :btree
  add_index "posts", ["trusted"], name: "trusted_index", using: :btree
  add_index "posts", ["user_id", "conversation"], name: "index_posts_on_user_id_and_conversation", using: :btree
  add_index "posts", ["user_id", "created_at"], name: "user_id_and_created_at_index", using: :btree
  add_index "posts", ["user_id"], name: "user_id_index", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",              limit: 255
    t.string   "hashed_password",       limit: 255
    t.string   "email",                 limit: 255
    t.datetime "created_at"
    t.datetime "last_active"
    t.integer  "inviter_id",            limit: 4
    t.string   "realname",              limit: 255
    t.datetime "updated_at"
    t.text     "description",           limit: 65535
    t.boolean  "banned",                              default: false, null: false
    t.boolean  "user_admin",                          default: false, null: false
    t.boolean  "moderator",                           default: false, null: false
    t.boolean  "admin",                               default: false, null: false
    t.boolean  "trusted",                             default: false, null: false
    t.integer  "posts_count",           limit: 4,     default: 0,     null: false
    t.string   "location",              limit: 255
    t.date     "birthday"
    t.string   "stylesheet_url",        limit: 255
    t.string   "gamertag",              limit: 255
    t.string   "msn",                   limit: 255
    t.string   "gtalk",                 limit: 255
    t.string   "aim",                   limit: 255
    t.string   "twitter",               limit: 255
    t.string   "flickr",                limit: 255
    t.string   "last_fm",               limit: 255
    t.string   "website",               limit: 255
    t.boolean  "notify_on_message",                   default: true,  null: false
    t.integer  "available_invites",     limit: 4,     default: 0,     null: false
    t.float    "latitude",              limit: 24
    t.float    "longitude",             limit: 24
    t.string   "facebook_uid",          limit: 255
    t.integer  "participated_count",    limit: 4,     default: 0,     null: false
    t.integer  "favorites_count",       limit: 4,     default: 0,     null: false
    t.integer  "following_count",       limit: 4,     default: 0,     null: false
    t.string   "time_zone",             limit: 255
    t.datetime "banned_until"
    t.string   "mobile_stylesheet_url", limit: 255
    t.string   "theme",                 limit: 255
    t.string   "mobile_theme",          limit: 255
    t.string   "instagram",             limit: 255
    t.string   "persistence_token",     limit: 255
    t.integer  "public_posts_count",    limit: 4,     default: 0,     null: false
    t.integer  "hidden_count",          limit: 4,     default: 0,     null: false
    t.string   "preferred_format",      limit: 255
    t.string   "sony",                  limit: 255
    t.integer  "avatar_id",             limit: 4
    t.text     "previous_usernames",    limit: 65535
    t.string   "nintendo",              limit: 255
    t.string   "steam",                 limit: 255
    t.string   "battlenet",             limit: 255
  end

  add_index "users", ["username"], name: "username_index", length: {"username"=>250}, using: :btree

end
