class Event < ActiveRecord::Base
  validates_presence_of :name
  
  belongs_to :application
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
