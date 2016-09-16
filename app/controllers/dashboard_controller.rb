class DashboardController < ApplicationController

  def index
    @people             = Person.order('created_at DESC').where('signup_at > :startdate AND verified LIKE :verify AND active = :active', { startdate: 1.week.ago, verify: '%Verified%', active: true })
    @submissions        = Submission.order('created_at DESC').where('person_id is ? AND created_at > ?', nil, 4.weeks.ago)
    @recent_signups     = @people.size
    @recent_submissions = @submissions.size
    @top_five_wards     = Person.group(:geography_id).order('count_all DESC').limit(5).count
    @bottom_five_wards  = Person.group(:geography_id).order('count_all ASC').limit(5).count
    @deactivated        = Person.unscoped.where(active: false).where('deactivated_at > ?', 1.week.ago).size
  end

end
