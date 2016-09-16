# == Schema Information
#
# Table name: taggings
#
#  id            :integer          not null, primary key
#  taggable_type :string(255)
#  taggable_id   :integer
#  created_by    :integer
#  created_at    :datetime
#  updated_at    :datetime
#  tag_id        :integer
#

class Tagging < ActiveRecord::Base
  has_paper_trail
  belongs_to :tag, counter_cache: true
  belongs_to :taggable, polymorphic: true, touch: true
  after_destroy :destroy_orphaned_tag
  before_create  :increment_counter
  before_destroy :decrement_counter

  attr_accessor :name
  validates_uniqueness_of :tag_id, scope: [:taggable_id, :taggable_type]

  private

    def destroy_orphaned_tag
      tag.destroy if Tagging.where(tag_id: tag.id).size.zero?
    end

    # increments the right classifiable counter for the right taxonomy
    def increment_counter
      taggable_type.constantize.increment_counter('tag_count_cache', taggable_id)
    end

    # decrements the right classifiable counter for the right taxonomy
    def decrement_counter
      taggable_type.constantize.decrement_counter('tag_count_cache', taggable_id)
    end

end
