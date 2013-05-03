class Submission < ActiveRecord::Base
  validates_presence_of :person, :raw_content
  belongs_to :person
  
  def fields
    # return the set of fields that make up a submission
    #  { field_id => 'field description' }
  
    # FIXME: handle subfields
    @fields ||= JSON::parse(field_structure)['Fields'].inject({}){ |acc, i| acc[i['ID']] = {title: i['Title'], type: i['Type']}; acc }
  end
  
  def field_label(field_id)
    fields[field_id][:title]
  end
  
  def field_value(field_id)
    JSON::parse(raw_content)[field_id]
  end
  
end
