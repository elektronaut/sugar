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

ActiveRecord::Schema.define(version: 20180315195139) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "avatars", id: :serial, force: :cascade do |t|
    t.string "content_hash"
    t.string "content_type"
    t.integer "content_length"
    t.string "filename"
    t.string "colorspace"
    t.integer "real_width"
    t.integer "real_height"
    t.integer "crop_width"
    t.integer "crop_height"
    t.integer "crop_start_x"
    t.integer "crop_start_y"
    t.integer "crop_gravity_x"
    t.integer "crop_gravity_y"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "conversation_relationships", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "conversation_id"
    t.boolean "notifications", default: true, null: false
    t.boolean "new_posts", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_conversation_relationships_on_conversation_id"
    t.index ["user_id"], name: "index_conversation_relationships_on_user_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.string "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "discussion_relationships", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "discussion_id"
    t.boolean "participated", default: false, null: false
    t.boolean "following", default: true, null: false
    t.boolean "favorite", default: false, null: false
    t.boolean "trusted", default: false, null: false
    t.boolean "hidden", default: false, null: false
    t.index ["discussion_id"], name: "index_discussion_relationships_on_discussion_id"
    t.index ["favorite"], name: "index_discussion_relationships_on_favorite"
    t.index ["following"], name: "index_discussion_relationships_on_following"
    t.index ["hidden"], name: "index_discussion_relationships_on_hidden"
    t.index ["participated"], name: "index_discussion_relationships_on_participated"
    t.index ["trusted"], name: "index_discussion_relationships_on_trusted"
    t.index ["user_id"], name: "index_discussion_relationships_on_user_id"
  end

  create_table "exchange_moderators", id: :serial, force: :cascade do |t|
    t.integer "exchange_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exchange_id"], name: "index_exchange_moderators_on_exchange_id"
    t.index ["user_id"], name: "index_exchange_moderators_on_user_id"
  end

  create_table "exchange_views", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "exchange_id"
    t.integer "post_id"
    t.integer "post_index", default: 0, null: false
    t.index ["exchange_id"], name: "index_exchange_views_on_exchange_id"
    t.index ["post_id"], name: "index_exchange_views_on_post_id"
    t.index ["user_id", "exchange_id"], name: "index_exchange_views_on_user_id_and_exchange_id"
    t.index ["user_id"], name: "index_exchange_views_on_user_id"
  end

  create_table "exchanges", id: :serial, force: :cascade do |t|
    t.string "title"
    t.boolean "sticky", default: false, null: false
    t.boolean "closed", default: false, null: false
    t.boolean "nsfw", default: false, null: false
    t.boolean "trusted", default: false, null: false
    t.integer "poster_id"
    t.integer "last_poster_id"
    t.integer "closer_id"
    t.integer "posts_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_post_at"
    t.string "type", limit: 100
    t.index ["created_at"], name: "index_exchanges_on_created_at"
    t.index ["last_post_at"], name: "index_exchanges_on_last_post_at"
    t.index ["poster_id"], name: "index_exchanges_on_poster_id"
    t.index ["sticky", "last_post_at"], name: "index_exchanges_on_sticky_and_last_post_at"
    t.index ["sticky"], name: "index_exchanges_on_sticky"
    t.index ["trusted"], name: "index_exchanges_on_trusted"
    t.index ["type"], name: "index_exchanges_on_type"
  end

  create_table "invites", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "email"
    t.string "token"
    t.text "message"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.string "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.string "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "password_reset_tokens", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_password_reset_tokens_on_user_id"
  end

  create_table "post_images", id: :serial, force: :cascade do |t|
    t.string "content_hash"
    t.string "content_type"
    t.integer "content_length"
    t.string "filename"
    t.string "colorspace"
    t.integer "real_width"
    t.integer "real_height"
    t.integer "crop_width"
    t.integer "crop_height"
    t.integer "crop_start_x"
    t.integer "crop_start_y"
    t.integer "crop_gravity_x"
    t.integer "crop_gravity_y"
    t.string "original_url", limit: 4096
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "content_hash"], name: "index_post_images_on_id_and_content_hash", unique: true
    t.index ["original_url"], name: "index_post_images_on_original_url"
  end

  create_table "posts", id: :serial, force: :cascade do |t|
    t.text "body"
    t.text "body_html"
    t.integer "user_id"
    t.integer "exchange_id"
    t.boolean "trusted", default: false, null: false
    t.boolean "conversation", default: false, null: false
    t.string "format", default: "markdown", null: false
    t.datetime "edited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deleted", default: false, null: false
    t.index ["conversation"], name: "index_posts_on_conversation"
    t.index ["created_at"], name: "index_posts_on_created_at"
    t.index ["deleted"], name: "index_posts_on_deleted"
    t.index ["exchange_id", "created_at"], name: "index_posts_on_exchange_id_and_created_at"
    t.index ["exchange_id"], name: "index_posts_on_exchange_id"
    t.index ["trusted"], name: "index_posts_on_trusted"
    t.index ["user_id", "conversation"], name: "index_posts_on_user_id_and_conversation"
    t.index ["user_id", "created_at"], name: "index_posts_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "username", limit: 100
    t.string "realname"
    t.string "email"
    t.string "hashed_password"
    t.string "location"
    t.string "gamertag"
    t.string "stylesheet_url"
    t.text "description"
    t.boolean "banned", default: false, null: false
    t.boolean "admin", default: false, null: false
    t.boolean "trusted", default: false, null: false
    t.boolean "user_admin", default: false, null: false
    t.boolean "moderator", default: false, null: false
    t.boolean "notify_on_message", default: true, null: false
    t.datetime "last_active"
    t.date "birthday"
    t.integer "posts_count", default: 0, null: false
    t.integer "inviter_id"
    t.string "msn"
    t.string "gtalk"
    t.string "aim"
    t.string "twitter"
    t.string "flickr"
    t.string "last_fm"
    t.string "website"
    t.float "longitude"
    t.float "latitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "available_invites", default: 0, null: false
    t.string "facebook_uid"
    t.integer "participated_count", default: 0, null: false
    t.integer "favorites_count", default: 0, null: false
    t.integer "following_count", default: 0, null: false
    t.string "time_zone"
    t.datetime "banned_until"
    t.string "mobile_stylesheet_url"
    t.string "theme"
    t.string "mobile_theme"
    t.string "instagram"
    t.string "persistence_token"
    t.integer "public_posts_count", default: 0, null: false
    t.integer "hidden_count", default: 0, null: false
    t.string "preferred_format"
    t.string "sony"
    t.integer "avatar_id"
    t.text "previous_usernames"
    t.string "nintendo"
    t.string "steam"
    t.string "battlenet"
    t.string "nintendo_switch"
    t.boolean "memorialized", default: false, null: false
    t.index ["last_active"], name: "index_users_on_last_active"
    t.index ["username"], name: "index_users_on_username"
  end

end
