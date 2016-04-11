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

  belongs_to :tag, counter_cache: true
  belongs_to :taggable, polymorphic: true, touch: true
  after_destroy :destroy_orphaned_tag

  attr_accessor :name

  validates_uniqueness_of :tag_id, scope: [:taggable_id, :taggable_type]

  private

    def destroy_orphaned_tag
      tag.destroy if Tagging.where(tag_id: tag.id).size == 0
    end

end
