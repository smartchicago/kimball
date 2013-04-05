class SearchController < ApplicationController
  def index    
    @results = if params[:q]
      Person.search params[:q], :per_page => 100
    elsif params[:adv]
      # advanced search
      # supported values:
      #   first_name
      #   last_name
      #   email_address
      #   device_description
      #   connection_description
      #   postal_code      
      Person.complex_search(params)
    
    else
      []
    end    
  end
end
