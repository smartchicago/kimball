class Program < ActiveRecord::Base
  validates_presence_of :name
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
