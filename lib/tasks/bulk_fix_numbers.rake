namespace :bulk_fix_numbers do
	desc "Normalize PeopleNumbers"
	task :PeopleNumbers => :environment do
	  Person.find_each do |person|
	  	if person.phone_number.present?
	  	  new_num = person.normalized_phone_number
	  	  new_num_length = new_num.length
	  	  if !(person.phone_number == new_num)
	        if (new_num_length == 12)
		  	  puts "Old Number: #{person.phone_number} | New Number: #{new_num} | New Number Length: #{new_num_length}"
			  person.phone_number= new_num
		      person.save
		    end
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
	  	  	if (new_num.length == 12)
	  	      puts "Old To: #{message.to} | New To: #{new_num}"
		      message.to = new_num
		    end
	      end
	    end
        new_num = ''
	    if message.from.present?
	  	  new_num = message.normalized_from
	  	  if !(message.from == new_num)
	  	  	if (new_num.length == 12)
	  	      puts "Old From: #{message.from} | New From: #{new_num}"
		      message.from = new_num
		    end
	      end
	    end
	    message.save
      end
	end

	
end
