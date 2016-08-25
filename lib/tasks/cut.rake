namespace :cut do
  desc "approve an user account"
  task :approve, [:email] => [:environment] do |t, args|
    user = User.find_by_email(args.email)
    if user
      print "Approving #{user.email} ... "
      user.approve!
      puts "done."
    else
      puts "error: could not find user with email #{args.email}"
    end
  end

  task :unapprove, [:email] => [:environment] do |t, args|
    user = User.find_by_email(args.email)
    if user
      print "Unapproving #{user.email} ... "
      user.unapprove!
      puts "done."
    else
      puts "error: could not find user with email #{args.email}"
    end
  end

  namespace :wufoo do
    desc "submit a signup as if it were from wufoo"
    task :signup, [:env] => [:environment] do |t,args|
      hosts = { development: 'http://localhost:8080', staging: "https://#{ENV['STAGING_SERVER']}", production: "https://#{ENV['PRODUCTION_SERVER']}" }

      post_body = {}
      for f,v in Person::WUFOO_FIELD_MAPPING do
        default_value = "#{v.to_s.humanize} #{Process.pid}"
        print "#{v.to_s.humanize} [#{default_value}]:"
        STDOUT.flush
        alt_value = STDIN.gets.strip!
        post_body[f] = alt_value.present? ? alt_value : default_value
      end

      curl_str = "curl -X POST #{hosts[args.env.to_sym]}/people #{post_body.collect{|k,v| "-d #{k}=\"#{v}\"" }.join(' ') } -d HandshakeKey=#{Logan::Application.config.wufoo_handshake_key}"

      puts "running: #{curl_str}"
      `#{curl_str}`
      puts "done."
    end
  end

  desc "shuffle names to kinda-anonymize data. useful for demos, etc"
  task :shuffle => :environment do
    puts "cowardly refusing to shuffle production data!" and return if Rails.env.production?

    Person.all.each do |person|
      person.first_name = Faker::Name.first_name
      person.last_name = Faker::Name.last_name
      person.email_address = Faker::Internet.email
      person.phone_number = Faker::PhoneNumber.cell_phone
      begin; person.save!; rescue; puts "failed to save person #{person.id}"; end
    end
  end
end
