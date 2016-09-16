namespace :tags do
  desc 'resets the tagging counter cache on the tags table'
  task reset_counter_caches: :environment do
    Tag.find_each { |tag| Tag.reset_counters(tag.id, :taggings) }
    Person.find_each { |p| p.update_attribute(:tag_count_cache, p.tag_count) }
  end

  desc 'delete unused tags'
  task delete_unused_tags: :environment do
    Tag.where(taggings_count: 0).find_each(&:destroy)
  end
end
