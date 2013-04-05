class Person < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks 
  
  # mapping do
  #         indexes :id,           :index    => :not_analyzed
  #         indexes :title,        :analyzer => 'snowball', :boost => 100
  #         indexes :content,      :analyzer => 'snowball'
  #         indexes :content_size, :as       => 'content.size'
  #         indexes :author,       :analyzer => 'keyword'
  #         indexes :published_on, :type => 'date', :include_in_all => false
  # end

  # t.string   "first_name"
  # t.string   "last_name"
  #   t.string   "email_address"
  #   t.string   "address_1"
  #   t.string   "address_2"
  #   t.string   "city"
  #   t.string   "state"
  #   t.string   "postal_code"
  #   t.integer  "geography_id"
  #   t.integer  "primary_device_id"
  #   t.string   "primary_device_description"
  #   t.integer  "secondary_device_id"
  #   t.string   "secondary_device_description"
  #   t.integer  "primary_connection_id"
  #   t.string   "primary_connection_description"
  #   t.string   "phone_number"
  #   t.string   "participation_type"
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   

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

  def primary_device_type_name
    Logan::Application.config.device_mappings.rassoc(primary_device_id)[0].to_s
  end

  def secondary_device_type_name
    Logan::Application.config.device_mappings.rassoc(secondary_device_id)[0].to_s
  end
  

end
