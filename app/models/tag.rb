class Tag < ActiveRecord::Base
  has_many :taggings
  
  attr_accessor :tag_count
  
  def self.most_popular(limit = 10)
    return @most_popular if @most_popular
    
    res = ActiveRecord::Base.connection.execute("SELECT tag_id, COUNT(tag_id) AS cnt FROM taggings GROUP BY tag_id ORDER BY cnt DESC LIMIT #{limit}")
    tags = Tag.find(res.collect{|r| r['tag_id']})
    tags.each{ |tag| tag.tag_count = res.find{|t| t['tag_id'] == tag.id }['cnt'] }
    @most_popular = tags.sort{|a,b| b.tag_count <=> a.tag_count }
  end
end
