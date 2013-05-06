class DashboardController < ApplicationController
  def index
    @people       = Person.order('created_at DESC').where("created_at > ?", 1.week.ago)
    @submissions  = Submission.order('created_at DESC').where("created_at > ?", 1.week.ago)    
  end
end
