class Feedlet < ActiveRecord::Base
  belongs_to :deal
  belongs_to :user
  belongs_to :posting_user, :class_name => 'User'

  def as_json(options = {})
    self.deal.try(:as_json, options).try(:merge, {:reposted_by => self.reposted_by})
  end
end
