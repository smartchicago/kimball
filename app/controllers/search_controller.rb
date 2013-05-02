require 'csv'

class SearchController < ApplicationController
  def index
    # no pagination for CSV export
    per_page = request.format.to_s.eql?('text/csv') ? 10000 : Person.per_page
    
    @results = if params[:q]
      Person.search params[:q], per_page: per_page, page: (params[:page] || 1)
    elsif params[:adv]
      Person.complex_search(params, per_page) # FIXME: more elegant solution for returning all records
    else
      []
    end    

    respond_to do |format|
      format.html { }
      format.csv { } 
    end

  end
end
