# == Schema Information
#
# Table name: events
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  description    :text
#  starts_at      :datetime
#  ends_at        :datetime
#  location       :text
#  address        :text
#  capacity       :integer
#  application_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#  created_by     :integer
#  updated_by     :integer
#

class Event < ActiveRecord::Base
  validates_presence_of :name, :application_id, :location, :address, :starts_at, :ends_at, :description
  
  belongs_to :application

  has_many :reservations
  has_many :people, through: :reservations
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
