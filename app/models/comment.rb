# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  content          :text
#  user_id          :integer
#  commentable_type :string(255)
#  commentable_id   :integer
#  created_at       :datetime
#  updated_at       :datetime
#  created_by       :integer
#

class Comment < ActiveRecord::Base

  validates_presence_of :content
  belongs_to :commentable, polymorphic: true, touch: true
end
