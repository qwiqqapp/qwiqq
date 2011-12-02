class UserEvent < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :user
  belongs_to :created_by, :class_name => "User"
  belongs_to :deal
  belongs_to :comment

  serialize :metadata

  before_save :update_cached_attributes

  validates :event_type, :inclusion => [ "comment", "like", "share", "follower" ]
  validates :user, :presence => true
  validates :created_by, :presence => true

  scope :read, where(:read => true)
  scope :unread, where(:read => false) do
    def clear
      unread.update_all(:read => true)
    end
  end

  default_scope :order => "created_at DESC"

  def as_json(options={})
    json = { 
      :type => event_type,
      :created_by_id => created_by_id,
      :created_by_username => created_by_username,
      :created_by_photo => created_by_photo,
      :created_by_photo_2x => created_by_photo_2x,
      :short_age => short_time_ago_in_words(created_at)
    }

    if deal
      json[:deal_name] = deal_name
      json[:deal_id] = deal_id
    end

    case event_type
    when "comment"
      json[:body] = metadata[:body]
    when "share"
      json[:service] = metadata[:service]
    end

    json
  end

  private
    def update_cached_attributes
      self.created_by_photo = created_by.photo(:iphone_small)
      self.created_by_photo_2x = created_by.photo(:iphone_small_2x)
      self.created_by_username = created_by.username
      self.deal_name = deal.name if deal
    end
end

