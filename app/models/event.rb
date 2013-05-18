class Event < ActiveRecord::Base
  validates_presence_of :name, :application_id, :location, :address, :starts_at, :ends_at, :description
  
  belongs_to :application

  has_many :reservations
  has_many :people, through: :reservations
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
