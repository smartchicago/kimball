# == Schema Information
#
# Table name: tags
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  created_by     :integer
#  created_at     :datetime
#  updated_at     :datetime
#  taggings_count :integer          default(0), not null
#

class Tag < ActiveRecord::Base

  validates_uniqueness_of :name
  validates_presence_of   :name

  has_many :taggings

  def tag_count
    taggings_count
  end

  # needed for tokenfield.
  # https://github.com/sliptree/bootstrap-tokenfield/issues/189
  def value
    id
  end

  def label
    name
  end

  def self.most_popular(limit = 10)
    Tag.all.order(taggings_count: :desc).limit(limit)
  end

end
