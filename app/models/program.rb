# == Schema Information
#
# Table name: programs
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text(65535)
#  created_at  :datetime
#  updated_at  :datetime
#  created_by  :integer
#  updated_by  :integer
#

class Program < ActiveRecord::Base

  validates_presence_of :name

  has_many :applications

  def to_param
    "#{id}-#{name.parameterize}"
  end

end
