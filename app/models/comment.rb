class Comment < ActiveRecord::Base
  validates_presence_of :content
  belongs_to :commentable, polymorphic: true, touch: true
end
