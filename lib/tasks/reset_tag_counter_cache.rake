namespace :reset_counter_caches do
	desc "resets the tagging counter cache on the tags table"
	task :tags => :environment do
	  Tags.find_each { |tag| Tags.reset_counters(tag.id, :taggings) }
	end
end
