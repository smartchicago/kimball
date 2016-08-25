# == Schema Information
#
# Table name: people
#
#  id                               :integer          not null, primary key
#  first_name                       :string(255)
#  last_name                        :string(255)
#  email_address                    :string(255)
#  address_1                        :string(255)
#  address_2                        :string(255)
#  city                             :string(255)
#  state                            :string(255)
#  postal_code                      :string(255)
#  geography_id                     :integer
#  primary_device_id                :integer
#  primary_device_description       :string(255)
#  secondary_device_id              :integer
#  secondary_device_description     :string(255)
#  primary_connection_id            :integer
#  primary_connection_description   :string(255)
#  phone_number                     :string(255)
#  participation_type               :string(255)
#  created_at                       :datetime
#  updated_at                       :datetime
#  signup_ip                        :string(255)
#  signup_at                        :datetime
#  voted                            :string(255)
#  called_311                       :string(255)
#  secondary_connection_id          :integer
#  secondary_connection_description :string(255)
#  verified                         :string(255)
#  preferred_contact_method         :string(255)
#  token                            :string(255)
#

module PeopleHelper

  def address_fields_to_sentence(person)
    [person.address_1, person.address_2, person.city, person.state, person.postal_code].reject(&:blank?).join(', ')
  end

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Style/RescueEnsureAlignment
  def human_device_type_name(device_id)
    Logan::Application.config.device_mappings.rassoc(device_id)[0].to_s; rescue; 'Unknown/No selection'
  end
  # rubocop:enable Style/RescueEnsureAlignment

  def human_connection_type_name(connection_id)
    mappings = { phone: 'Phone with data plan',
                 home_broadband: 'Home broadband (cable, DSL)',
                 other: 'Other',
                 public_computer: 'Public computer',
                 public_wifi: 'Public wifi' }

    begin; mappings[Logan::Application.config.connection_mappings.rassoc(connection_id)[0]]; rescue; 'Unknown/No selection'; end
  end

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Style/MethodName
  #
  def sendToMailChimp(person)
    if person.email_address.present? && person.verified.start_with?('Verified')
      begin
        gibbon = Gibbon::Request.new
        gibbon.lists(Logan::Application.config.cut_group_mailchimp_list_id).members(Digest::MD5.hexdigest(new_person.email_address.downcase)).upsert(
          body: { email_address: new_person.email_address.downcase,
                  status: 'subscribed',
                  merge_fields: { FNAME: person.first_name,
                                  LNAME: person.last_name,
                                  MMERGE3: person.geography_id,
                                  MMERGE4: person.postal_code,
                                  MMERGE5: person.participation_type,
                                  MMERGE6: person.voted,
                                  MMERGE7: person.called_311,
                                  MMERGE8: person.primary_device_description,
                                  MMERGE9: person.secondary_device_id,
                                  MMERGE10: person.secondary_device_description,
                                  MMERGE11: person.primary_connection_id,
                                  MMERGE12: person.primary_connection_description,
                                  MMERGE13: person.primary_device_id,
                                  MMERGE14: person.preferred_contact_method } }
        )

      rescue Gibbon::MailChimpError => e
        Rails.logger.fatal("[People_Helper->sendToMailChimp] fatal error sending #{person.id} to Mailchimp: #{e.message}")
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Style/MethodName

end
