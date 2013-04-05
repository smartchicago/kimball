class SearchController < ApplicationController
  def index    
    if params[:q]
      @results = Person.search params[:q], :per_page => 100
    elsif params[:adv]
      # advanced search
      # supported values:
      #   first_name
      #   last_name
      #   email_address
      #   device_description
      #   connection_description
      #   postal_code      
      @results = Person.complex_search(params)
    end
  end
end
