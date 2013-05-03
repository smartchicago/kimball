class Submission < ActiveRecord::Base
  validates_presence_of :person, :raw_content
  belongs_to :person
end
