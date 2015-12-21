namespace :check_wufoo_forms do
  desc "check wufoo forms for non-GSM characters"
	task :badGsmCheck => :environment do
	  wufoo = WuParty.new(ENV['WUFOO_ACCOUNT'],ENV['WUFOO_API'])
      forms = wufoo.forms
      for form in forms
      	fields = form.flattened_fields
      	for field in fields
          title = field['Title']
          canEncode = GSMEncoder.can_encode?(title)
          if !canEncode
            puts title
            puts "-----------"
          end
      	end
      end

	end

end