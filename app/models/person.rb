class Person < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks 
  include ExternalDataMappings
  
  self.per_page = 15

  WUFOO_FIELD_MAPPING = { 
    'Field1' =>  :first_name,
    'Field2' =>  :last_name,
    'Field10' =>  :email_address,
    'Field14' =>  :voted,
    'Field17'=>   :called_311, 
    'Field20' =>  :primary_device_id, # type of primary
    'Field21' =>  :primary_device_description, # desc of primary
    'Field23' => :secondary_device_id,
    'Field24' => :secondary_device_description, # desc of secondary
    'Field26' => :primary_connection_id, # connection type
    'Field27' => :primary_connection_description, # description of connection
    'Field29' => :participation_type, # participation type
    'Field31' => :geography_id, # geography_id
    'Field4' => :address_1, # address_1
    'Field7' => :postal_code, # postal_code
    'Field9' => :phone_number, # phone_number
    'IP'    => :signup_ip, # client IP, ignored for the moment
    # 'HandshakeKey' => 'b51c04fdaf7f8f333061f09f623d9d5b04f12b19' # secret code, ignored          
  }

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
      indexes :phone_number, analyzer: "keyword"
      indexes :postal_code, analyzer: "keyword"
      indexes :geography_id, index: :not_analyzed

      # device types
      indexes :primary_device_type_name, analyzer: :snowball
      indexes :secondary_device_type_name, analyzer: :snowball

      # device descriptions
      indexes :primary_device_description
      indexes :secondary_device_description
      indexes :primary_connection_description
      
      indexes :created_at, type: "date"
    end
  end  

  def self.complex_search(params)
    tire.search per_page: 100 do
      query do
        boolean do
          must { string "first_name:#{params[:first_name]}"} if params[:first_name].present?
          must { string "last_name:#{params[:last_name]}"} if params[:last_name].present?
          must { string "email_address:#{params[:email_address]}"} if params[:email_address].present?
          must { string "postal_code:#{params[:postal_code]}"} if params[:postal_code].present?
          must { string "primary_device_description:#{params[:device_description]} OR secondary_device_description:#{params[:device_description]}"} if params[:device_description].present?
          must { string "primary_connection_description:#{params[:connection_description]}"} if params[:connection_description].present?
        end
      end      
    end
  end

  def self.initialize_from_wufoo(params)
    new_person = Person.new
    params.each_pair do |k,v|
      new_person[WUFOO_FIELD_MAPPING[k]] = v if WUFOO_FIELD_MAPPING[k].present?
    end
    
    # rewrite the device and connection identifiers to integers
    new_person.primary_device_id      = Person.map_device_to_id(params[WUFOO_FIELD_MAPPING.rassoc(:primary_device_id).first])
    new_person.secondary_device_id    = Person.map_device_to_id(params[WUFOO_FIELD_MAPPING.rassoc(:secondary_device_id).first])
    new_person.primary_connection_id  = Person.map_connection_to_id(params[WUFOO_FIELD_MAPPING.rassoc(:primary_connection_id).first])
    
    new_person
  end

  def primary_device_type_name
    Logan::Application.config.device_mappings.rassoc(primary_device_id)[0].to_s
  end

  def secondary_device_type_name
    Logan::Application.config.device_mappings.rassoc(secondary_device_id)[0].to_s
  end

end
