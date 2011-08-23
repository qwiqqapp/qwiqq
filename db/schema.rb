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

ActiveRecord::Schema.define(:version => 20110823190816) do

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["name"], :name => "index_categories_on_name"

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "deal_id"
    t.string   "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "notification_sent_at"
  end

  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "deals", :force => true do |t|
    t.string   "name"
    t.integer  "price"
    t.integer  "percent"
    t.integer  "user_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean  "premium",            :default => false
    t.float    "lat"
    t.float    "lon"
    t.integer  "comments_count",     :default => 0
    t.integer  "likes_count",        :default => 0
    t.string   "location_name"
    t.datetime "indexed_at"
    t.string   "unique_token"
  end

  add_index "deals", ["likes_count", "comments_count"], :name => "index_deals_on_likes_count_and_comments_count"
  add_index "deals", ["unique_token"], :name => "index_deals_on_unique_token", :unique => true
  add_index "deals", ["user_id"], :name => "index_deals_on_user_id"

  create_table "feedlets", :force => true do |t|
    t.integer  "deal_id"
    t.integer  "user_id"
    t.string   "reposted_by"
    t.datetime "created_at"
    t.integer  "posting_user_id"
    t.datetime "timestamp"
  end

  add_index "feedlets", ["created_at"], :name => "index_feedlets_on_created_at"
  add_index "feedlets", ["posting_user_id"], :name => "index_feedlets_on_posting_user_id"
  add_index "feedlets", ["user_id"], :name => "index_feedlets_on_user_id"

  create_table "geo_blocks", :force => true do |t|
    t.integer "location_id", :limit => 8, :null => false
    t.integer "ip_start",    :limit => 8, :null => false
    t.integer "ip_end",      :limit => 8, :null => false
    t.integer "index_geo",   :limit => 8, :null => false
  end

  add_index "geo_blocks", ["index_geo"], :name => "index_geo_blocks_on_index_geo"
  add_index "geo_blocks", ["ip_end"], :name => "index_geo_blocks_on_ip_end"
  add_index "geo_blocks", ["ip_start"], :name => "index_geo_blocks_on_ip_start"

  create_table "geo_locations", :force => true do |t|
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "postal_code"
    t.float  "latitude"
    t.float  "longitude"
    t.string "metro_code"
    t.string "area_code"
  end

  create_table "invitations", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.string   "service",      :null => false
    t.string   "email"
    t.datetime "created_at"
    t.datetime "delivered_at"
  end

  create_table "likes", :force => true do |t|
    t.integer  "deal_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "notification_sent_at"
  end

  add_index "likes", ["deal_id"], :name => "index_likes_on_deal_id"
  add_index "likes", ["user_id"], :name => "index_likes_on_user_id"

  create_table "relationships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "notification_sent_at"
  end

  add_index "relationships", ["target_id"], :name => "index_relationships_on_target_id"
  add_index "relationships", ["user_id", "target_id"], :name => "index_relationships_on_user_id_and_target_id", :unique => true
  add_index "relationships", ["user_id"], :name => "index_relationships_on_user_id"

  create_table "reposts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "deal_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reposts", ["user_id"], :name => "index_reposts_on_user_id"

  create_table "shares", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "deal_id",    :null => false
    t.string   "service",    :null => false
    t.string   "email"
    t.datetime "created_at"
    t.datetime "shared_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "city"
    t.string   "country"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.string   "facebook_access_token"
    t.string   "twitter_access_token"
    t.boolean  "send_notifications",     :default => true
    t.integer  "followers_count",        :default => 0,    :null => false
    t.integer  "following_count",        :default => 0,    :null => false
    t.integer  "friends_count",          :default => 0,    :null => false
    t.string   "twitter_access_secret"
    t.string   "twitter_id"
    t.string   "facebook_id"
    t.string   "bio"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "notifications_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
