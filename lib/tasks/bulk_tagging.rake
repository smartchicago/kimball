namespace :bulk_tag_persons do
	desc "Bulk add taggings"
	task :add, [:tag,:taggable_type,:ids] => :environment do |task, args|
		@tag = Tag.find_or_initialize_by(name: args.tag)
	    #@tag.created_by ||= 1
	    ids = args[:ids].split ' '
		ids.each do |p|
	    	@tagging = Tagging.new(taggable_type: args.taggable_type, taggable_id: p, tag: @tag)
	        @tagging.save
	        puts @tagging
	    end
	end
end
