namespace :bulk_contact_method do
	desc "Bulk set blank preferred contact method as EMAIL"
	task :bulkAllBlank => :environment do

	  Person.find_each do |person|
	  	if person.preferred_contact_method.blank?
	  	  puts person
		  	person.preferred_contact_method = "EMAIL"
	      person.save
	    end
      end
	end


end
