Gibbon.api_key = ENV['MAILCHIMP_API_KEY']
#Gibbon versions > 0.4.6 below
#Gibbon::Request.api_key = ENV['MAILCHIMP_API_KEY']

Logan::Application.config.cut_group_mailchimp_list_id = ENV['MAILCHIMP_LIST_ID'] # the list that we will add all static segements to
