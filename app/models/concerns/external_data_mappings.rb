require 'active_support/concern'

module ExternalDataMappings
  extend ActiveSupport::Concern
  
  module ClassMethods
    def map_connection_to_id(val)
      sym = case val
      when "Broadband at home (cable, DSL, etc.)", "Broadband at home (e.g. cable or DSL)"
        :home_broadband
      when "Public computer center"
        :public_computer
      when "Phone plan with data"
        :phone
      when "Public wi-fi", "Public Wi-Fi"
        :public_wifi
      else
        :other
      end

      Logan::Application.config.connection_mappings[sym]    
    end

    def map_device_to_id(val)
        sym = case val
        when "Laptop"
          :laptop
        when "Smart phone", "Smart phone (e.g. iPhone or Android phone)"
          :smartphone
        when "Desktop computer"
          :desktop
        when "Tablet", "Tablet (e.g. iPad)"
          :tablet
        end

        ret = Logan::Application.config.device_mappings[sym]
        Rails.logger.debug "[map_device_to_id] given <<#{val}>> returning <<#{ret}>>"
        ret
    end
  end
end