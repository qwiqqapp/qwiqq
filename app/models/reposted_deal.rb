class RepostedDeal < ActiveRecord::Base
  belongs_to :user
  belongs_to :deal

  validates :user, :presence => true
  validates :deal, :presence => true
end
