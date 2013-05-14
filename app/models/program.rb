class Program < ActiveRecord::Base
  validates_presence_of :name

  has_many :applications
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
