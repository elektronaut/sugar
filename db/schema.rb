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

ActiveRecord::Schema.define(version: 2019_06_26_225031) do

  create_table "avatars", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversation_relationships", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "conversation_id"
    t.boolean "notifications", default: true, null: false
    t.boolean "new_posts", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["conversation_id"], name: "conversation_id_index"
    t.index ["user_id"], name: "user_id_index"
  end

  create_table "delayed_jobs", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler", collation: "latin1_swedish_ci"
    t.string "last_error", collation: "latin1_swedish_ci"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by", collation: "latin1_swedish_ci"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discussion_relationships", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "discussion_id"
    t.boolean "participated", default: false, null: false
    t.boolean "following", default: true, null: false
    t.boolean "favorite", default: false, null: false
    t.boolean "trusted", default: false, null: false
    t.boolean "hidden", default: false, null: false
    t.index ["discussion_id"], name: "discussion_id_index"
    t.index ["favorite"], name: "favorite_index"
    t.index ["following"], name: "following_index"
    t.index ["hidden"], name: "index_discussion_relationships_on_hidden"
    t.index ["participated"], name: "participated_index"
    t.index ["trusted"], name: "trusted_index"
    t.index ["user_id"], name: "user_id_index"
  end

  create_table "exchange_moderators", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "exchange_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exchange_id"], name: "index_exchange_moderators_on_exchange_id"
    t.index ["user_id"], name: "index_exchange_moderators_on_user_id"
  end

  create_table "exchange_views", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "exchange_id"
    t.integer "post_id"
    t.integer "post_index", default: 0, null: false
    t.index ["exchange_id"], name: "discussion_id_index"
    t.index ["post_id"], name: "post_id_index"
    t.index ["user_id", "exchange_id"], name: "user_id_discussion_id_index", unique: true
    t.index ["user_id"], name: "user_id_index"
  end

  create_table "exchanges", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "poster_id"
    t.integer "last_poster_id"
    t.boolean "closed", default: false, null: false
    t.boolean "sticky", default: false, null: false
    t.string "title"
    t.datetime "created_at"
    t.datetime "last_post_at"
    t.datetime "updated_at"
    t.boolean "nsfw", default: false, null: false
    t.boolean "trusted", default: false, null: false
    t.integer "posts_count", default: 0
    t.integer "closer_id"
    t.string "type", collation: "utf8_general_ci"
    t.index ["created_at"], name: "created_at_index"
    t.index ["last_post_at"], name: "last_post_at_index"
    t.index ["poster_id"], name: "poster_id_index"
    t.index ["sticky", "last_post_at"], name: "sticky"
    t.index ["sticky"], name: "sticky_index"
    t.index ["title"], name: "discussions_title_fulltext", type: :fulltext
    t.index ["trusted"], name: "trusted_index"
    t.index ["type"], name: "type_index"
  end

  create_table "invites", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "email"
    t.string "token"
    t.text "message"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_access_grants", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false, collation: "latin1_swedish_ci"
    t.integer "expires_in", null: false
    t.string "redirect_uri", null: false, collation: "latin1_swedish_ci"
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes", collation: "latin1_swedish_ci"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id", null: false
    t.string "token", null: false, collation: "latin1_swedish_ci"
    t.string "refresh_token", collation: "latin1_swedish_ci"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes", collation: "latin1_swedish_ci"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false, collation: "latin1_swedish_ci"
    t.string "uid", null: false, collation: "latin1_swedish_ci"
    t.string "secret", null: false, collation: "latin1_swedish_ci"
    t.string "redirect_uri", null: false, collation: "latin1_swedish_ci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "owner_id"
    t.string "owner_type", collation: "latin1_swedish_ci"
    t.string "scopes", default: "", null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "password_reset_tokens", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "token", collation: "latin1_swedish_ci"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_password_reset_tokens_on_user_id"
  end

  create_table "post_images", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
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
    t.string "original_url", limit: 4096
    t.index ["id", "content_hash"], name: "index_post_images_on_id_and_content_hash", unique: true
    t.index ["original_url"], name: "index_post_images_on_original_url", length: 250
  end

  create_table "posts", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "exchange_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "body"
    t.string "format_type", collation: "utf8_general_ci"
    t.text "body_html"
    t.datetime "edited_at"
    t.boolean "trusted", default: false, null: false
    t.boolean "conversation", default: false, null: false
    t.string "format", default: "markdown", null: false, collation: "utf8_general_ci"
    t.boolean "deleted", default: false, null: false
    t.index ["conversation"], name: "type_index"
    t.index ["created_at"], name: "created_at_index"
    t.index ["deleted"], name: "index_posts_on_deleted"
    t.index ["exchange_id", "created_at"], name: "discussion_id"
    t.index ["exchange_id"], name: "discussion_id_index"
    t.index ["trusted"], name: "trusted_index"
    t.index ["user_id", "conversation"], name: "index_posts_on_user_id_and_conversation"
    t.index ["user_id", "created_at"], name: "user_id_and_created_at_index"
    t.index ["user_id"], name: "user_id_index"
  end

  create_table "users", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "username"
    t.string "hashed_password", collation: "utf8_general_ci"
    t.string "email", collation: "utf8_general_ci"
    t.datetime "created_at"
    t.datetime "last_active"
    t.integer "inviter_id"
    t.string "realname"
    t.datetime "updated_at"
    t.text "description"
    t.boolean "user_admin", default: false, null: false
    t.boolean "moderator", default: false, null: false
    t.boolean "admin", default: false, null: false
    t.boolean "trusted", default: false, null: false
    t.integer "posts_count", default: 0, null: false
    t.string "location"
    t.date "birthday"
    t.string "stylesheet_url", collation: "utf8mb4_general_ci"
    t.string "gamertag", collation: "utf8mb4_general_ci"
    t.string "msn", collation: "utf8mb4_general_ci"
    t.string "gtalk", collation: "utf8mb4_general_ci"
    t.string "aim", collation: "utf8mb4_general_ci"
    t.string "twitter", collation: "utf8mb4_general_ci"
    t.string "flickr", collation: "utf8mb4_general_ci"
    t.string "last_fm", collation: "utf8mb4_general_ci"
    t.string "website", collation: "utf8mb4_general_ci"
    t.boolean "notify_on_message", default: true, null: false
    t.integer "available_invites", default: 0, null: false
    t.float "latitude"
    t.float "longitude"
    t.string "facebook_uid", collation: "utf8_general_ci"
    t.integer "participated_count", default: 0, null: false
    t.integer "favorites_count", default: 0, null: false
    t.integer "following_count", default: 0, null: false
    t.string "time_zone", collation: "utf8_general_ci"
    t.datetime "banned_until"
    t.string "mobile_stylesheet_url", collation: "utf8_general_ci"
    t.string "theme", collation: "utf8_general_ci"
    t.string "mobile_theme", collation: "utf8_general_ci"
    t.string "instagram", collation: "utf8_general_ci"
    t.string "persistence_token", collation: "utf8_general_ci"
    t.integer "public_posts_count", default: 0, null: false
    t.integer "hidden_count", default: 0, null: false
    t.string "preferred_format", collation: "utf8_general_ci"
    t.string "sony"
    t.integer "avatar_id"
    t.text "previous_usernames"
    t.string "nintendo"
    t.string "steam"
    t.string "battlenet"
    t.string "nintendo_switch"
    t.integer "status", default: 0, null: false
    t.index ["username"], name: "username_index", length: 250
  end

end
