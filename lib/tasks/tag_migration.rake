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
		people_tags.each{|k,v|
			begin
				person = people.find{|p| p.id == k}
				# use below if we want owned tags.
				#		user = user.find{|u| u.id == v.created_by}
				#		user.tag(person, with: v, on: 'tags') # keeps the relationships
				person.delay.tag_list.add(v)
			rescue Exception => e
				 errors << [k,e]
			end
		}
		puts errors
	end
end
