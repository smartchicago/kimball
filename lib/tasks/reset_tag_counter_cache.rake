namespace :tags do
	desc "resets the tagging counter cache on the tags table"
	task :reset_counter_caches => :environment do
	  Tag.find_each { |tag| Tag.reset_counters(tag.id, :taggings) }
	end

	desc "delete unused tags"
	task :delete_unused_tags => :environment do
		Tag.where(taggings_count: 0).find_each do |tag|
			tag.destroy
		end
	end
end
