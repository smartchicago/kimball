class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, polymorphic: true, touch: true

  attr_accessor :name
  
  validates_uniqueness_of :tag_id, scope: [:taggable_id, :taggable_type]
end
