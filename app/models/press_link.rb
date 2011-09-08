class PressLink < ActiveRecord::Base
  validates_presence_of :published_at
  validates_presence_of :publication_name
  validates_presence_of :article_title
  validates_presence_of :url
end
