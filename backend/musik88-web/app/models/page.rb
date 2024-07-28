class Page < ActiveRecord::Base
  validates_length_of :page_slug, presence: true, allow_blank: false
  validates_length_of :page_content, presence: true, allow_blank: false

  has_many :comments, as: :commentable

  enum category: %i[
    about
    what_is_this
  ]
end
