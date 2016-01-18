# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_by :integer
#  created_at :datetime
#  updated_at :datetime
#

class Tag < ActiveRecord::Base

  validates_uniqueness_of :name

  has_many :taggings

  attr_accessor :tag_count

  def self.most_popular(limit = 10)
    return @most_popular if @most_popular

    res = ActiveRecord::Base.connection.execute("SELECT tag_id, COUNT(tag_id) AS cnt FROM taggings GROUP BY tag_id ORDER BY cnt DESC LIMIT #{limit}")
    tags = Tag.find(res.collect { |r| r[0] })
    tags.each { |tag| tag.tag_count = res.find { |t| t[0] == tag.id }[1] }
    @most_popular = tags.sort { |a, b| b.tag_count <=> a.tag_count }
  end

end
