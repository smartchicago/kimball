class Application < ActiveRecord::Base
  validates_presence_of :name, :description
  
  def to_param
    "#{id}-#{name.parameterize}"
  end  
end
