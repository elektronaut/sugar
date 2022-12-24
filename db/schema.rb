# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_12_24_122008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "conversation_relationships", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "conversation_id"
    t.boolean "notifications", default: true, null: false
    t.boolean "new_posts", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["conversation_id", "user_id"], name: "index_conversation_relationships_on_conversation_id_and_user_id", unique: true
    t.index ["conversation_id"], name: "index_conversation_relationships_on_conversation_id"
    t.index ["user_id"], name: "index_conversation_relationships_on_user_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.string "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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

  create_table "dynamic_image_variants", force: :cascade do |t|
    t.string "image_type", null: false
    t.bigint "image_id", null: false
    t.string "content_hash", null: false
    t.string "content_type", null: false
    t.integer "content_length", null: false
    t.string "filename", null: false
    t.string "format", null: false
    t.integer "width", null: false
    t.integer "height", null: false
    t.integer "crop_width", null: false
    t.integer "crop_height", null: false
    t.integer "crop_start_x", null: false
    t.integer "crop_start_y", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["image_id", "image_type", "format", "width", "height", "crop_width", "crop_height", "crop_start_x", "crop_start_y"], name: "dynamic_image_variants_by_format_and_size", unique: true
    t.index ["image_id", "image_type"], name: "dynamic_image_variants_by_image"
    t.index ["image_type", "image_id"], name: "index_dynamic_image_variants_on_image_type_and_image_id"
  end

  create_table "exchange_moderators", id: :serial, force: :cascade do |t|
    t.integer "exchange_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["exchange_id", "user_id"], name: "index_exchange_moderators_on_exchange_id_and_user_id", unique: true
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "last_post_at", precision: nil
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
    t.datetime "expires_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.string "redirect_uri", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "scopes"
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.string "redirect_uri", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "edited_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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

  create_table "user_mutes", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "muted_user_id"
    t.bigint "exchange_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["exchange_id"], name: "index_user_mutes_on_exchange_id"
    t.index ["muted_user_id", "user_id", "exchange_id"], name: "index_user_mutes_on_muted_user_id_and_user_id_and_exchange_id", unique: true
    t.index ["muted_user_id"], name: "index_user_mutes_on_muted_user_id"
    t.index ["user_id"], name: "index_user_mutes_on_user_id"
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
    t.boolean "admin", default: false, null: false
    t.boolean "trusted", default: false, null: false
    t.boolean "user_admin", default: false, null: false
    t.boolean "moderator", default: false, null: false
    t.boolean "notify_on_message", default: true, null: false
    t.datetime "last_active", precision: nil
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "available_invites", default: 0, null: false
    t.string "facebook_uid"
    t.integer "participated_count", default: 0, null: false
    t.integer "favorites_count", default: 0, null: false
    t.integer "following_count", default: 0, null: false
    t.string "time_zone"
    t.datetime "banned_until", precision: nil
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
    t.integer "status", default: 0, null: false
    t.string "pronouns"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["last_active"], name: "index_users_on_last_active"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
