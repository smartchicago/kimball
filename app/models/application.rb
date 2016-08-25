# == Schema Information
#
# Table name: applications
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  description  :text(65535)
#  url          :string(255)
#  source_url   :string(255)
#  creator_name :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  program_id   :integer
#  created_by   :integer
#  updated_by   :integer
#

class Application < ActiveRecord::Base

  validates_presence_of :name, :description
  validates_presence_of :program_id

  belongs_to :program
  has_many   :events

  def to_param
    "#{id}-#{name.parameterize}"
  end

end
