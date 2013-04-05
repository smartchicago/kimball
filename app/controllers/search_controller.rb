class SearchController < ApplicationController
  def index    
    if params[:q]
      @results = Person.search params[:q]
    end
  end
end
