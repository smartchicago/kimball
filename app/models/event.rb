class Event < ActiveRecord::Base
  validates_presence_of :name
  
  belongs_to :application

  has_many :reservations
  has_many :people, through: :reservations
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
