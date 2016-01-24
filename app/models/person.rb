# == Schema Information
#
# Table name: people
#
#  id                               :integer          not null, primary key
#  first_name                       :string(255)
#  last_name                        :string(255)
#  email_address                    :string(255)
#  address_1                        :string(255)
#  address_2                        :string(255)
#  city                             :string(255)
#  state                            :string(255)
#  postal_code                      :string(255)
#  geography_id                     :integer
#  primary_device_id                :integer
#  primary_device_description       :string(255)
#  secondary_device_id              :integer
#  secondary_device_description     :string(255)
#  primary_connection_id            :integer
#  primary_connection_description   :string(255)
#  phone_number                     :string(255)
#  participation_type               :string(255)
#  created_at                       :datetime
#  updated_at                       :datetime
#  signup_ip                        :string(255)
#  signup_at                        :datetime
#  voted                            :string(255)
#  called_311                       :string(255)
#  secondary_connection_id          :integer
#  secondary_connection_description :string(255)
#  verified                         :string(255)
#  preferred_contact_method         :string(255)
#

class Person < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks 
  include ExternalDataMappings

  validates   :phone_number, length: { is: 10 }

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :submissions, dependent: :destroy

  has_many :reservations, dependent: :destroy
  has_many :events, through: :reservations

  has_many :tags, through: :taggings
  has_many :taggings, as: :taggable

  after_update  :sendToMailChimp
  after_create  :sendToMailChimp
  
  self.per_page = 15

  WUFOO_FIELD_MAPPING = { 
    'Field1'  =>  :first_name,
    'Field2'  =>  :last_name,
    'Field10' =>  :email_address,
    'Field261' =>  :voted,
    'Field262' =>  :called_311, 
    'Field39' =>  :primary_device_id, # type of primary
    'Field21' =>  :primary_device_description, # desc of primary
    'Field40' =>  :secondary_device_id,
    'Field24' =>  :secondary_device_description, # desc of secondary
    'Field41' =>  :primary_connection_id, # connection type
    #'Field41' =>  :primary_connection_description, # description of connection
    'Field42' =>  :secondary_connection_id, # connection type
    #'Field42' =>  :secondary_connection_description, # description of connection
    'Field268' =>  :address_1, # address_1
    'Field269' =>  :city, # city
    #'Field47' =>  :state, # state
    'Field271'  =>  :postal_code, # postal_code
    'Field9'  =>  :phone_number, # phone_number
    'IP'      =>  :signup_ip, # client IP, ignored for the moment

  }

  # update index if a comment is added
  after_touch() { tire.update_index }

  # namespace indices
  index_name "person-#{Rails.env}"

  settings analysis: {
    analyzer: {
      email_analyzer: {
        tokenizer: "uax_url_email",
        filter: ["lowercase"],
        type: "custom"
      }
    }
  } do
    mapping do
      indexes :id, index: :not_analyzed 
      indexes :first_name
      indexes :last_name
      indexes :email_address, analyzer: "email_analyzer"
      indexes :phone_number, index: :not_analyzed
      indexes :postal_code, index: :not_analyzed
      indexes :geography_id, index: :not_analyzed
      indexes :address_1  # FIXME: if we ever use address_2, this will not work
      indexes :city
      indexes :verified, analyzer: :snowball
      
      # device types
      indexes :primary_device_type_name, analyzer: :snowball
      indexes :secondary_device_type_name, analyzer: :snowball

      indexes :primary_device_id
      indexes :secondary_device_id

      # device descriptions
      indexes :primary_device_description
      indexes :secondary_device_description
      indexes :primary_connection_description
      indexes :secondary_connection_description
      
      # comments
      indexes :comments do
        indexes :content, analyzer: "snowball"
      end
      
      # events
      indexes :reservations do
        indexes :event_id, index: :not_analyzed
      end
      
      # submissions
      # indexes the output of the Submission#indexable_values method      
      indexes :submissions, analyzer: :snowball
      
      # tags
      indexes :tag_values, analyzer: :keyword

      indexes :preferred_contact_method
      
      indexes :created_at, type: "date"
    end
  end  


  def to_indexed_json
    # customize what data is sent to ES for indexing
    to_json( 
      methods: [ :tag_values ],
      include: {        
        submissions: {
          only:  [ :submission_values ],
          methods: [ :submission_values ]
        },
        comments: { 
          only: [ :content ] 
        }, 
        reservations: { 
          only: [ :event_id ] 
        } 
      } 
    )
  end

  def tag_values
    tags.collect(&:name)
  end

  def self.complex_search(params, _per_page)
    options = {}
    options[:per_page] = _per_page
    options[:page]     = params[:page] || 1
    
    if !(params[:device_id_type].blank?) 
      device_id_string = params[:device_id_type].join(' ')
    end

    if !(params[:connection_id_type].blank?) 
      connection_id_string = params[:connection_id_type].join(' ')
    end

    tire.search options do
      query do
        boolean do
          must { string "first_name:#{params[:first_name]}"} if params[:first_name].present?
          must { string "last_name:#{params[:last_name]}"} if params[:last_name].present?
          must { string "email_address:(#{params[:email_address]})"} if params[:email_address].present?
          must { string "postal_code:(#{params[:postal_code]})"} if params[:postal_code].present?
          must { string "verified:(#{params[:verified]})"} if params[:verified].present?
          must { string "primary_device_description:#{params[:device_description]} OR secondary_device_description:#{params[:device_description]}"} if params[:device_description].present?
          must { string "primary_connection_description:#{params[:connection_description]} OR secondary_connection_description:#{params[:connection_description]}"} if params[:connection_description].present?
          must { string "primary_device_id:#{device_id_string} OR secondary_device_id:#{device_id_string}"} if params[:device_id_type].present?
          must { string "primary_connection_id:#{connection_id_string} OR secondary_connection_id:#{connection_id_string}"} if params[:connection_id_type].present?
          must { string "geography_id:(#{params[:geography_id]})"} if params[:geography_id].present?
          must { string "event_id:#{params[:event_id]}"} if params[:event_id].present?          
          must { string "address_1:#{params[:address]}"} if params[:address].present?
          must { string "city:#{params[:city]}"} if params[:city].present?
          must { string "submission_values:#{params[:submissions]}"} if params[:submissions].present?
          # must { string "tag_values:#{tags_string}"} if params[:tags].present?
          must { string "preferred_contact_method:#{params[:preferred_contact_method]}"} if !params[:preferred_contact_method].blank?
        end
      end 
      filter :terms, :tag_values => params[:tags] if params[:tags].present?     
    end
  end


  def self.initialize_from_wufoo_sms(params)
    new_person = Person.new
    
    # Save to Person
    new_person.first_name = params['Field275']
    new_person.last_name = params['Field276']
    new_person.address_1 = params["Field268"]
    new_person.postal_code = params["Field271"]
    new_person.email_address = params["Field279"]
    new_person.phone_number = params["field281"]
    case params["Field39"].upcase
    when "A"
      new_person.primary_device_id = Person.map_device_to_id("Desktop computer")
    when "B"
      new_person.primary_device_id = Person.map_device_to_id("Laptop")
    when "C"
      new_person.primary_device_id = Person.map_device_to_id("Tablet")
    when "D"
      new_person.primary_device_id = Person.map_device_to_id("Smart phone")
    else
      new_person.primary_device_id = params["Field39"]
    end
    
    new_person.primary_device_description = params["Field21"]


    case params["Field41"].upcase
    when "A"
      new_person.primary_connection_id = Person.primary_connection_id("Broadband at home")
    when "B"
      new_person.primary_connection_id = Person.primary_connection_id("Phone plan with data")
    when "C"
      new_person.primary_connection_id = Person.primary_connection_id("Public wi-fi")
    when "D"
      new_person.primary_connection_id = Person.primary_connection_id("Public computer center")
    else
      new_person.primary_connection_id = params["Field41"]
    end
    
    if params['Field278'].upcase == "TEXT"
      new_person.preferred_contact_method = "SMS"
    else
      new_person.preferred_contact_method = "EMAIL"
    end
    
    new_person.verified = "Verified by Text Message Signup"
    new_person.signup_at = Time.now


    new_person

  end

  def sendToMailChimp
    if self.email_address.present? 
      if self.verified.present?
        if self.verified.start_with?("Verified")
            begin
              mailchimpSend = Gibbon.list_subscribe({
                :id => Logan::Application.config.cut_group_mailchimp_list_id, 
                :email_address => self.email_address, 
                :double_optin => 'false', 
                :update_existing => 'true',
                :merge_vars => {:FNAME => self.first_name, 
                  :LNAME => self.last_name, 
                  :MMERGE3 => self.geography_id, 
                  :MMERGE4 => self.postal_code, 
                  :MMERGE5 => self.participation_type, 
                  :MMERGE6 => self.voted, 
                  :MMERGE7 => self.called_311, 
                  :MMERGE8 => self.primary_device_description, 
                  :MMERGE9 => secondary_device_type_name, 
                  :MMERGE10 => self.secondary_device_description, 
                  :MMERGE11 =>  primary_connection_type_name , 
                  :MMERGE12 => self.primary_connection_description, 
                  :MMERGE13 => primary_device_type_name, 
                  :MMERGE14 => self.preferred_contact_method}
                  })
              Rails.logger.info("[People->sendToMailChimp] Sent #{self.id} to Mailchimp: #{mailchimpSend}")
            rescue Gibbon::MailChimpError => e
              Rails.logger.fatal("[People->sendToMailChimp] fatal error sending #{self.id} to Mailchimp: #{e.message}")
            end
        end
      end
    end
  end


  def self.initialize_from_wufoo(params)
    new_person = Person.new
    params.each_pair do |k,v|
      new_person[WUFOO_FIELD_MAPPING[k]] = v if WUFOO_FIELD_MAPPING[k].present?
    end
    
    # Special handling of participation type. New form uses 2 fields where old form used 1. Need to combine into one. Manually set to "Either one" if both field53 & field54 are populated.
    if params['Field53'] != '' and params['Field54'] != ''
      new_person.participation_type = "Either one"
    elsif params['Field53'] != ''
      new_person.participation_type = params['Field53']
    else
      new_person.participation_type = params['Field54']
    end
        
    if params['Field273'] == "Email"
      new_person.preferred_contact_method = "EMAIL"
    else
      new_person.preferred_contact_method = "SMS"
    end

    # Copy connection descriptions to description fields
    new_person.primary_connection_description = new_person.primary_connection_id
    new_person.secondary_connection_description = new_person.secondary_connection_id

    # rewrite the device and connection identifiers to integers
    new_person.primary_device_id        = Person.map_device_to_id(params[WUFOO_FIELD_MAPPING.rassoc(:primary_device_id).first])
    new_person.secondary_device_id      = Person.map_device_to_id(params[WUFOO_FIELD_MAPPING.rassoc(:secondary_device_id).first])
    new_person.primary_connection_id    = Person.map_connection_to_id(params[WUFOO_FIELD_MAPPING.rassoc(:primary_connection_id).first])
    new_person.secondary_connection_id  = Person.map_connection_to_id(params[WUFOO_FIELD_MAPPING.rassoc(:secondary_connection_id).first])

    # FIXME: this is a hack, since we need to initialize people 
    # with a city/state, but don't ask for it in the Wufoo form
    #new_person.city  = "Chicago" With update we ask for city
    new_person.state = "Illinois"
    
    new_person.signup_at = Time.now
    
    new_person
  end

  def primary_device_type_name
    if primary_device_id.present?
      Logan::Application.config.device_mappings.rassoc(primary_device_id)[0].to_s
    end
  end

  def secondary_device_type_name
    if secondary_device_id.present?
      Logan::Application.config.device_mappings.rassoc(secondary_device_id)[0].to_s
    end
  end

  def primary_connection_type_name
    if primary_connection_id.present?
      Logan::Application.config.connection_mappings.rassoc(primary_connection_id)[0].to_s
    end
  end

  def secondary_connection_type_name
    if secondary_connection_id.present?
      Logan::Application.config.connection_mappings.rassoc(secondary_connection_id)[0].to_s
    end
  end

  def full_name
    [first_name, last_name].join(" ")
  end

end
