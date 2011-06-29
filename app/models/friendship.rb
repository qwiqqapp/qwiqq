class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User"

  PENDING = 0
  ACCEPTED = 1
  REJECTED = 2

  scope :pending, where("status = #{PENDING}")
  scope :accepted, where("status = #{ACCEPTED}")
  scope :rejected, where("status = #{REJECTED}")

  def accept!
    update_attribute(:status, ACCEPTED)
  end

  def reject!
    update_attribute(:status, REJECTED)
  end
end
