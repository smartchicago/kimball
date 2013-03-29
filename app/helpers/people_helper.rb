module PeopleHelper
  def address_fields_to_sentence(person)
    [person.address_1, person.address_2, person.city, person.state, person.postal_code].reject{|i| i.blank? }.join(", ")
  end

end
