class Person < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks 
  include ExternalDataMappings

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :submissions, dependent: :destroy

  has_many :reservations, dependent: :destroy
  has_many :events, through: :reservations

  has_many :tags, through: :taggings
  has_many :taggings, as: :taggable
  
  self.per_page = 15

  WUFOO_FIELD_MAPPING = { 
    'Field1'  =>  :first_name,
    'Field2'  =>  :last_name,
    'Field10' =>  :email_address,
    'Field153' =>  :voted,
    'Field154' =>  :called_311, 
    'Field39' =>  :primary_device_id, # type of primary
    'Field21' =>  :primary_device_description, # desc of primary
    'Field40' =>  :secondary_device_id,
    'Field24' =>  :secondary_device_description, # desc of secondary
    'Field41' =>  :primary_connection_id, # connection type
    #'Field41' =>  :primary_connection_description, # description of connection
    'Field42' =>  :secondary_connection_id, # connection type
    #'Field42' =>  :secondary_connection_description, # description of connection
    'Field44' =>  :address_1, # address_1
    'Field46' =>  :city, # city
    'Field48'  =>  :postal_code, # postal_code
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
      
      # device types
      indexes :primary_device_type_name, analyzer: :snowball
      indexes :secondary_device_type_name, analyzer: :snowball

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
    
    tire.search options do
      query do
        boolean do
          must { string "first_name:#{params[:first_name]}"} if params[:first_name].present?
          must { string "last_name:#{params[:last_name]}"} if params[:last_name].present?
          must { string "email_address:(#{params[:email_address]})"} if params[:email_address].present?
          must { string "postal_code:(#{params[:postal_code]})"} if params[:postal_code].present?
          must { string "primary_device_description:#{params[:device_description]} OR secondary_device_description:#{params[:device_description]}"} if params[:device_description].present?
          must { string "primary_connection_description:#{params[:connection_description]} OR secondary_connection_description:#{params[:connection_description]}"} if params[:connection_description].present?
          must { string "geography_id:(#{params[:geography_id]})"} if params[:geography_id].present?
          must { string "event_id:#{params[:event_id]}"} if params[:event_id].present?          
          must { string "address_1:#{params[:address]}"} if params[:address].present?
          must { string "city:#{params[:city]}"} if params[:city].present?
          must { string "submission_values:#{params[:submissions]}"} if params[:submissions].present?
          must { string "tag_values:#{params[:tags]}"} if params[:tags].present?
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
    Logan::Application.config.device_mappings.rassoc(primary_device_id)[0].to_s
  end

  def secondary_device_type_name
    Logan::Application.config.device_mappings.rassoc(secondary_device_id)[0].to_s
  end

  def full_name
    [first_name, last_name].join(" ")
  end

end
