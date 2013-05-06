module PeopleHelper
  def address_fields_to_sentence(person)
    [person.address_1, person.address_2, person.city, person.state, person.postal_code].reject{|i| i.blank? }.join(", ")
  end

  def human_device_type_name(device_id)
    begin; Logan::Application.config.device_mappings.rassoc(device_id)[0].to_s; rescue; "Unknown/No selection"; end
  end

  def human_connection_type_name(connection_id)
    mappings = {:phone => "Phone with data plan", 
      :home_broadband => "Home broadband (cable, DSL)", 
      :other => "Other", 
      :public_computer => "Public computer", 
      :public_wifi => "Public wifi"
    }
    
    mappings[Logan::Application.config.connection_mappings.rassoc(connection_id)[0]]
  end
end