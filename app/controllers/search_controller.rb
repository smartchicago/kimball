require 'csv'

class SearchController < ApplicationController
  include PeopleHelper

  def index
    # no pagination for CSV export
    per_page = request.format.to_s.eql?('text/csv') ? 10000 : Person.per_page
    
    @results = if params[:q]
      Person.search params[:q], per_page: per_page, page: (params[:page] || 1)
    elsif params[:adv]
      Person.complex_search(params, per_page) # FIXME: more elegant solution for returning all records
    else
      []
    end    

    respond_to do |format|
      format.html { }
      format.csv {
        fields = Person.column_names 
        output = CSV.generate do |csv|
          # Generate the headers
          csv << fields.map {|f| f.titleize }

          # Some fields need a helper method
          human_devices = %w{ primary_device_id secondary_device_id }
          human_connections = %w{ primary_connection_id secondary_connection_id }

          # Write the results
          @results.each do |person|
            csv << fields.map do |f|
              field_value = person[f]
              cell_value = if human_devices.include? f
                human_device_type_name(field_value)
              elsif human_connections.include? f
                human_connection_type_name(field_value)
              else
                field_value
              end
            end
          end
        end 
        send_data output
      } 
    end

  end

  def export
    # send all results to a new static segment in mailchimp
    list_name = params.delete(:name)
    @people = Person.complex_search(params, 10000)
    @mce = MailchimpExport.new(name: list_name, recipients: @people.collect{ |person| person.email_address }, created_by: current_user.id)
    
    if @mce.with_user(current_user).save
      Rails.logger.info("[SearchController#export] Sent #{@mce.recipients.size} email addresses to a static segment named #{@mce.name}")
      respond_to do |format|
        format.js { }
      end
    else
      Rails.logger.error("[SearchController#export] failed to send event to mailchimp: #{@mce.errors.inspect}")
      format.all { render text: "failed to send event to mailchimp: #{@mce.errors.inspect}", status: 400} 
    end
    
  end
end
