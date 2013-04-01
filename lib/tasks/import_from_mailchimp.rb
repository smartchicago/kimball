require_relative "../../config/environment"

require 'csv'
require 'optparse'

class MailChimpImporter
  @options = {}
  
  def initialize(opts)
    @options = opts
  end
  
  def load_mailchimp_csv
    CSV.foreach(@options.mailchimp_infile, :headers => :first_row) do |line|
      # puts line.inspect

      person = Person.new
      column_map = {
        "Email Address" => :email_address,"First Name" => :first_name,"Last Name" => :last_name,"Ward" => :geography_id,
        "ZIP Code" => :postal_code,
        "How would you like to participate" => :participation_type, "Primary device" => :primary_device_id,"Primary device description" => :primary_device_description,
        "Secondary device" => :secondary_device_id, "Secondary device description" => :secondary_device_description ,"Primary connection method" => :primary_connection_id,
        "Connection method description" => :primary_connection_description
      } #   "Did you vote in the most recent election", "Have you ever called 311"
      
      column_map.each do |k,v|
        person[v] = if k == "Primary device" || k == "Secondary device" 
            map_device_to_id(line[k])
          elsif k == "Primary connection method"
            map_connection_to_id(line[k])
          else 
            line[k]
          end
      end
      
      person.save
    end
  end

  def load_wufoo_csv
    CSV.foreach(@options.wufoo_infile, :headers => :first_row) do |line|
      person = Person.find_by_email_address(line["Email"])
      
      next if person.blank?
      
      person.address_1 = line["Address"]
      person.phone_number = line["Phone Number"]
      person.postal_code = line["Zip code"]
      person.city = "Chicago"
      person.state = "Illinois"
      
      person.save
    end
  end

  def map_connection_to_id(val)
    sym = case val
    when "Broadband at home (cable, DSL, etc.)", "Broadband at home (e.g. cable or DSL)"
      :home_broadband
    when "Public computer center"
      :public_computer
    when "Phone plan with data"
      :phone
    when "Public wi-fi", "Public Wi-Fi"
      :public_wifi
    when "Other"
      :other
    end

    Logan::Application.config.connection_mappings[sym]    
  end
  
  def map_device_to_id(val)
      sym = case val
      when "Laptop"
        :laptop
      when "Smart phone", "Smart phone (e.g. iPhone or Android phone)"
        :smartphone
      when "Desktop computer"
        :desktop
      when "Tablet", "Tablet (e.g. iPad)"
        :tablet
      end
      
      Logan::Application.config.device_mappings[sym]
  end
  
  def run
    load_mailchimp_csv
    load_wufoo_csv
  end
  
end


###

options = OpenStruct.new
OptionParser.new do |opts|
  options.dryrun = false
  
  opts.banner = "Usage: import_from_mailchimp.rb [options]"  

  opts.on("-i", "--mc-infile FILE", "Input CSV") do |v|
    options.mailchimp_infile = v
  end

  opts.on("-w", "--wufoo-infile FILE", "Wufoo Input CSV") do |v|
    options.wufoo_infile = v
  end
  
  opts.on("-d", "--[no-]dry-run", "Dry run (if present will not commit changes)") do |v|
    options.dryrun = true
  end
  
end.parse!

MailChimpImporter.new(options).run