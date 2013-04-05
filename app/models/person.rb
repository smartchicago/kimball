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

  tire.mapping do
    indexes :id
    indexes :first_name
    indexes :last_name
  end
  
end
