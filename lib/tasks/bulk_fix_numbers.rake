namespace :bulk_fix_numbers do
	desc "Bulk remove +1 and - from person phone numbers"
	task :PeopleNumbers => :environment do
	  Person.find_each do |person|
	  	if person.phone_number.present?
	  	  new_num = person.phone_number.gsub("+1","").gsub("-","")
	  	  if !(person.phone_number == new_num)
	  	    puts person.phone_number
		    person.phone_number= new_num
	        person.save
	      end
	    end
      end
	end

	desc "Bulk remove +1 and - from twilio message phone numbers"
	task :TwilioMessageNumbers => :environment do
	  TwilioMessage.find_each do |message|
	  	if message.to.present?
	  	  new_num = message.to.gsub("+1","").gsub("-","")
	  	  if !(message.to == new_num)
	  	    puts message.to
		    message.to = new_num
	      end
	    end
        new_num = ''
	    if message.from.present?
	  	  new_num = message.from.gsub("+1","").gsub("-","")
	  	  if !(message.from == new_num)
	  	    puts message.from
		    message.from = new_num
	      end
	    end
	    message.save
      end
	end

	
end
