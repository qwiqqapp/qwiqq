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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121230195512) do

  create_table "active_admin_comments", :force => true do |t|
    t.integer   "resource_id",   :null => false
    t.string    "resource_type", :null => false
    t.integer   "author_id"
    t.string    "author_type"
    t.text      "body"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string    "email",                                                :null => false
    t.string    "encrypted_password",     :limit => 128,                :null => false
    t.string    "reset_password_token"
    t.timestamp "reset_password_sent_at"
    t.timestamp "remember_created_at"
    t.integer   "sign_in_count",                         :default => 0
    t.timestamp "current_sign_in_at"
    t.timestamp "last_sign_in_at"
    t.string    "current_sign_in_ip"
    t.string    "last_sign_in_ip"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "categories", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "categories", ["name"], :name => "index_categories_on_name"

  create_table "comments", :force => true do |t|
    t.integer   "user_id"
    t.integer   "deal_id"
    t.string    "body"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.timestamp "notification_sent_at"
  end

  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "deals", :force => true do |t|
    t.string    "name"
    t.integer   "price"
    t.integer   "percent"
    t.integer   "user_id"
    t.integer   "category_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "photo_file_name"
    t.string    "photo_content_type"
    t.integer   "photo_file_size"
    t.timestamp "photo_updated_at"
    t.boolean   "premium",               :default => false
    t.boolean   "hidden",               :default => false
    t.float     "lat"
    t.float     "lon"
    t.integer   "comments_count",        :default => 0
    t.integer   "likes_count",           :default => 0
    t.string    "location_name"
    t.string    "unique_token"
    t.timestamp "indexed_at"
    t.string    "foursquare_venue_id"
    t.string    "user_photo"
    t.string    "user_photo_2x"
    t.integer   "reposts_count",         :default => 0
    t.integer   "shares_count",          :default => 0
    t.string    "foursquare_venue_name"
    t.boolean   "coupon",                :default => false
    t.integer   "coupon_count",          :default => 0
    t.integer   "number_users_shared",   :default => 0
    t.boolean   "for_sale_on_paypal",    :default => false
    t.integer   "num_left_for_sale",     :default => 0
    t.integer   "num_for_sale",          :default => 0
    t.string    "currency"
    t.string    "paypal_email"
    t.integer   "transactions_count",    :default => 0
  end

  add_index "deals", ["likes_count", "comments_count"], :name => "index_deals_on_likes_count_and_comments_count"
  add_index "deals", ["transactions_count"], :name => "index_deals_on_transactions_count"
  add_index "deals", ["unique_token"], :name => "index_deals_on_unique_token", :unique => true
  add_index "deals", ["user_id"], :name => "index_deals_on_user_id"

  create_table "feedlets", :force => true do |t|
    t.integer   "deal_id"
    t.integer   "user_id"
    t.string    "reposted_by"
    t.timestamp "created_at"
    t.integer   "posting_user_id"
    t.timestamp "timestamp"
  end

  add_index "feedlets", ["created_at"], :name => "index_feedlets_on_created_at"
  add_index "feedlets", ["posting_user_id"], :name => "index_feedlets_on_posting_user_id"
  add_index "feedlets", ["user_id"], :name => "index_feedlets_on_user_id"

  create_table "invitations", :force => true do |t|
    t.integer   "user_id",      :null => false
    t.string    "service",      :null => false
    t.string    "email"
    t.timestamp "created_at"
    t.timestamp "delivered_at"
  end

  create_table "likes", :force => true do |t|
    t.integer   "deal_id"
    t.integer   "user_id"
    t.timestamp "created_at"
    t.timestamp "notification_sent_at"
  end

  add_index "likes", ["deal_id"], :name => "index_likes_on_deal_id"
  add_index "likes", ["user_id"], :name => "index_likes_on_user_id"

  create_table "press_links", :force => true do |t|
    t.string    "publication_name"
    t.text      "article_title"
    t.timestamp "published_at"
    t.string    "url"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "press_links", ["published_at"], :name => "index_press_links_on_published_at"

  create_table "push_devices", :force => true do |t|
    t.string    "token",              :null => false
    t.integer   "user_id"
    t.timestamp "last_registered_at"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "push_devices", ["token"], :name => "index_push_devices_on_token", :unique => true

  create_table "relationships", :force => true do |t|
    t.integer   "user_id"
    t.integer   "target_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.timestamp "notification_sent_at"
    t.boolean   "friends",              :default => false
  end

  add_index "relationships", ["friends"], :name => "index_relationships_on_friends"
  add_index "relationships", ["target_id"], :name => "index_relationships_on_target_id"
  add_index "relationships", ["user_id", "target_id"], :name => "index_relationships_on_user_id_and_target_id", :unique => true
  add_index "relationships", ["user_id"], :name => "index_relationships_on_user_id"

  create_table "reposts", :force => true do |t|
    t.integer   "user_id"
    t.integer   "deal_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "reposts", ["user_id"], :name => "index_reposts_on_user_id"

  create_table "shares", :force => true do |t|
    t.integer   "user_id",          :null => false
    t.integer   "deal_id",          :null => false
    t.string    "service",          :null => false
    t.string    "email"
    t.timestamp "created_at"
    t.timestamp "shared_at"
    t.string    "number"
    t.string    "message"
    t.string    "facebook_page_id"
  end

  create_table "transactions", :force => true do |t|
    t.string   "paypal_transaction_id"
    t.integer   "deal_id"
    t.integer   "user_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "user_events", :force => true do |t|
    t.integer   "user_id",                                      :null => false
    t.integer   "comment_id"
    t.integer   "like_id"
    t.integer   "share_id"
    t.integer   "relationship_id"
    t.integer   "deal_id"
    t.string    "deal_name"
    t.integer   "created_by_id",                                :null => false
    t.string    "created_by_photo",                             :null => false
    t.string    "created_by_photo_2x",                          :null => false
    t.string    "created_by_username",                          :null => false
    t.string    "event_type",                                   :null => false
    t.text      "metadata"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "read",                      :default => false
    t.boolean   "is_web_event",              :default => false
    t.timestamp "push_notification_sent_at"
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
    t.boolean  "send_notifications",       :default => true
    t.integer  "followers_count",          :default => 0,     :null => false
    t.integer  "following_count",          :default => 0,     :null => false
    t.integer  "friends_count",            :default => 0,     :null => false
    t.string   "twitter_access_secret"
    t.string   "twitter_id"
    t.string   "facebook_id"
    t.string   "bio"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "notifications_token"
    t.integer  "likes_count",              :default => 0
    t.integer  "comments_count",           :default => 0
    t.integer  "deals_count",              :default => 0
    t.string   "foursquare_id"
    t.string   "foursquare_access_token"
    t.string   "phone"
    t.string   "website"
    t.boolean  "suggested",                :default => false
    t.string   "current_facebook_page_id"
    t.string   "fbid"
    t.boolean  "sent_facebook_push",       :default => false
    t.string   "paypal_email"
    t.integer  "transactions_count",       :default => 0
    t.datetime "socialyzer_enabled_at"
    t.integer  "twitter_utc_offset"
    t.text     "socialyzer_times"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
