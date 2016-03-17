namespace :bulk_fix_numbers do
	desc "Normalize PeopleNumbers"
	task :PeopleNumbers => :environment do
	  Person.find_each do |person|
	  	if person.phone_number.present?
	  	  new_num = person.normalized_phone_number
	  	  if !(person.phone_number == new_num)
	  	    puts "Old Number: #{person.phone_number} | New Number: #{new_num}"
		    person.phone_number= new_num
	        person.save
	      end
	    end
      end
	end

	desc "Normalize twilio message phone numbers"
	task :TwilioMessageNumbers => :environment do
	  TwilioMessage.find_each do |message|
	  	if message.to.present?
	  	  new_num = message.normalized_to
	  	  if !(message.to == new_num)
	  	    puts "Old To: #{message.to} | New To: #{new_num}"
		    message.to = new_num
	      end
	    end
        new_num = ''
	    if message.from.present?
	  	  new_num = message.normalized_from
	  	  if !(message.from == new_num)
	  	    puts "Old From: #{message.to} | New From: #{new_num}"
		    message.from = new_num
	      end
	    end
	    message.save
      end
	end

	
end
