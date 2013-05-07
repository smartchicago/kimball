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
  
end