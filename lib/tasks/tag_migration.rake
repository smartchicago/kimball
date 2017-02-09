namespace :tag_migration do
	desc "Bulk add taggings by Id"
	task :migrate => :environment  do
		PaperTrail.enabled = false
		tags_results = ActiveRecord::Base.connection.exec_query('SELECT * FROM old_tags')
		taggings_results = ActiveRecord::Base.connection.exec_query('SELECT * FROM old_taggings')
		people = Person.all
		users = User.all

		people_tags = {}
		taggings_results.each do |tr|
			people_tags[tr["taggable_id"]] ||= []
			tag_names = tags_results.find{|t| t['id'] == tr['tag_id']}['name']
			people_tags[tr["taggable_id"]] << tag_names
		end
		errors = []
		people_tags.each{|person_id,tags|
			begin
				person = people.find{|p| p.id == person_id}
				# use below if we want owned tags.
				#		user = user.find{|u| u.id == v.created_by}
				#		user.tag(person, with: v, on: 'tags') # keeps the relationships
				next if person.nil? || tags.blank?
				#person.tag_list.add(v)
				#person.save
				Delayed::Job.enqueue TagPersonJob.new(person_id,tags)

			rescue Exception => e
				 errors << [person_id,e]
			end
		}
		puts errors
	end
end
