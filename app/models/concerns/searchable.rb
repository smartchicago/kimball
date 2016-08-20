require 'active_support/concern'

module Searchable

  extend ActiveSupport::Concern

  included do
    include Tire::Model::Search
    include Tire::Model::Callbacks

    # update index if a comment is added
    after_touch { tire.update_index }

    # namespace indices
    index_name "person-#{Rails.env}"

    settings analysis: {
      analyzer: {
        email_analyzer: {
          tokenizer: 'uax_url_email',
          filter: ['lowercase'],
          type: 'custom'
        }
      }
    } do
      mapping do
        indexes :id, index: :not_analyzed
        indexes :first_name
        indexes :last_name
        indexes :email_address, analyzer: 'email_analyzer'
        indexes :phone_number, index: :not_analyzed
        indexes :postal_code, index: :not_analyzed
        indexes :geography_id, index: :not_analyzed
        indexes :address_1 # FIXME: if we ever use address_2, this will not work
        indexes :city
        indexes :verified, analyzer: :snowball

        # device types
        indexes :primary_device_type_name, analyzer: :snowball
        indexes :secondary_device_type_name, analyzer: :snowball

        indexes :primary_device_id
        indexes :secondary_device_id

        # device descriptions
        indexes :primary_device_description
        indexes :secondary_device_description
        indexes :primary_connection_description
        indexes :secondary_connection_description

        # comments
        indexes :comments do
          indexes :content, analyzer: 'snowball'
        end

        # events
        indexes :reservations do
          indexes :event_id, index: :not_analyzed
        end

        # submissions
        # indexes the output of the Submission#indexable_values method
        indexes :submissions, analyzer: :snowball

        # tags
        indexes :tag_values, analyzer: :keyword

        indexes :preferred_contact_method

        indexes :created_at, type: 'date'
      end
    end
  end

  module ClassMethods

    # FIXME: Refactor and re-enable cop
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    #
    def complex_search(params, per_page)
      options = {}
      options[:per_page] = per_page
      options[:page]     = params[:page] || 1

      unless params[:device_id_type].blank?
        device_id_string = params[:device_id_type].join(' ')
      end

      unless params[:connection_id_type].blank?
        connection_id_string = params[:connection_id_type].join(' ')
      end

      tire.search options do
        query do
          boolean do
            must { string "first_name:#{params[:first_name]}" } if params[:first_name].present?
            must { string "last_name:#{params[:last_name]}" } if params[:last_name].present?
            must { string "email_address:(#{params[:email_address]})" } if params[:email_address].present?
            must { string "phone_number:(#{params[:phone_number]})" } if params[:phone_number].present?
            must { string "postal_code:(#{params[:postal_code]})" } if params[:postal_code].present?
            must { string "verified:(#{params[:verified]})" } if params[:verified].present?
            must { string "primary_device_description:#{params[:device_description]} OR secondary_device_description:#{params[:device_description]}" } if params[:device_description].present?
            must { string "primary_connection_description:#{params[:connection_description]} OR secondary_connection_description:#{params[:connection_description]}" } if params[:connection_description].present?
            must { string "primary_device_id:#{device_id_string} OR secondary_device_id:#{device_id_string}" } if params[:device_id_type].present?
            must { string "primary_connection_id:#{connection_id_string} OR secondary_connection_id:#{connection_id_string}" } if params[:connection_id_type].present?
            must { string "geography_id:(#{params[:geography_id]})" } if params[:geography_id].present?
            must { string "event_id:#{params[:event_id]}" } if params[:event_id].present?
            must { string "address_1:#{params[:address]}" } if params[:address].present?
            must { string "city:#{params[:city]}" } if params[:city].present?
            must { string "submission_values:#{params[:submissions]}" } if params[:submissions].present?
            # must { string "tag_values:#{tags_string}"} if params[:tags].present?
            must { string "preferred_contact_method:#{params[:preferred_contact_method]}" } unless params[:preferred_contact_method].blank?
          end
        end
        filter :terms, tag_values: params[:tags] if params[:tags].present?
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  end

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Metrics/MethodLength
  #
  def to_indexed_json
    # customize what data is sent to ES for indexing
    to_json(
      methods: [:tag_values],
      include: {
        submissions: {
          only:  [:submission_values],
          methods: [:submission_values]
        },
        comments: {
          only: [:content]
        },
        reservations: {
          only: [:event_id]
        }
      }
    )
  end
  # rubocop:enable Metrics/MethodLength

end
