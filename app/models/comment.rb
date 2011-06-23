class Comment < ActiveRecord::Base
  belongs_to :deal
  belongs_to :user

  validates_presence_of :deal, :user, :body
  
  default_scope :order => 'created_at desc'
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}

  after_create :deliver_notification
  after_create :increment_comment_count
  after_destroy :decrement_comment_count
  
  
  def as_json(options={})
    {
      :comment_id   => id.try(:to_s),
      :body         => body,
      :short_age    => short_created_at,
      :name         => user.name
    }
  end
  
  
  
  private
  def short_created_at
    from_time = created_at
    to_time = Time.now
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round

    case distance_in_minutes
    when 0..1
      "#{distance_in_seconds}s"
    when 2..44           then "#{distance_in_minutes}m"
    when 45..1439        then "#{(distance_in_minutes.to_f / 60.0).round}hr"
    when 1440..43199     then "#{(distance_in_minutes.to_f / 1440.0).round}d"
    when 43200..525599   then "#{(distance_in_minutes.to_f / 43200.0).round}mo"
    else
      "#{distance_in_minutes / 525600}y"
    end
  end
  
  
  def deliver_notification
    Notifications.deal_commented(self).deliver
  end

  def increment_comment_count
    Deal.increment_counter(:comment_count, deal_id)
  end
   
  def decrement_comment_count
    Deal.decrement_counter(:comment_count, deal_id)
  end
end
