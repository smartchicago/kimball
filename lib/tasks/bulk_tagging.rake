namespace :bulk_tagging do
	desc "Bulk add taggings by Id"
	task :addById, [:tag,:taggable_type,:ids] => :environment do |task, args|
		@tag = Tag.find_or_initialize_by(name: args.tag)
	    #@tag.created_by ||= 1
	    ids = args[:ids].split ' '
		ids.each do |p|
	    	@tagging = Tagging.new(taggable_type: args.taggable_type, taggable_id: p, tag: @tag)
	        @tagging.save
	        puts @tagging
	    end
	end

	desc "Bulk add taggings by email address"
	task :addByEmail, [:tag,:emails] => :environment do |task, args|
		@tag = Tag.find_or_initialize_by(name: args.tag)
	    #@tag.created_by ||= 1
	    emails = args[:emails].split ' '
		emails.each do |email|
			people = Person.where(email_address: email)
			people.each do |person|
				p = person.id
				if !p.nil?
			    	@tagging = Tagging.new(taggable_type: "Person", taggable_id: p, tag: @tag)
			        @tagging.save
			        puts @tagging
			    end
	 		end
	    end
	end
end
