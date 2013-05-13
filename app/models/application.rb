class Application < ActiveRecord::Base
  validates_presence_of :name, :description
  validates_presence_of :program_id  
  
  belongs_to :program
  
  def to_param
    "#{id}-#{name.parameterize}"
  end  
end
