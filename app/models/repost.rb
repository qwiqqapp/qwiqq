class Repost < ActiveRecord::Base
  belongs_to :user
  belongs_to :deal, :counter_cache => true, :touch => true
end
