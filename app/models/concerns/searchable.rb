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
        },
        phone_number: {
          tokenizer: 'my_ngram_tokenizer',
          filter: ['trim'],
          type: 'custom'
        }
      },
      tokenizer: {
        my_ngram_tokenizer: {
          type: 'nGram',
          min_gram: '8',
          max_gram: '11',
          token_chars: ['digit']
        }
      }
    } do
      mapping do
        indexes :id, index: :not_analyzed
        indexes :first_name, analyzer: :snowball
        indexes :last_name, analyzer: :snowball
        indexes :email_address, analyzer: 'email_analyzer'
        indexes :phone_number, index: 'phone_number'
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

      params.delete(:adv)
      params.delete(:page)

      params[:phone_number].delete!('^0-9') unless params[:phone_number].blank?

      unless params[:device_id_type].blank?
        device_id_string = params[:device_id_type].join(' ')
      end

      unless params[:connection_id_type].blank?
        connection_id_string = params[:connection_id_type].join(' ')
      end

      Person.tire.search options do
        query do
          boolean do
            params.each do |k, v|
              next unless v.present?
              next if v.blank?
              case k
              when :connection_description
                must { string "primary_connection_description:#{v} OR secondary_connection_description:#{v}" }
              when :device_description
                must { string "primary_device_description:#{v} OR secondary_device_description:#{v}" }
              when :device_id_type
                must { string "primary_device_id:#{device_id_string} OR secondary_device_id:#{device_id_string}" }
              when :tags
                must { string "tag_values:#{v}" }
              when :submissions
                must { string "submission_values:#{v}" }
              when :connection_id_type
                must { string "primary_connection_id:#{connection_id_string} OR secondary_connection_id:#{connection_id_string}" }
              when :address
                must { string "address_1:#{v}" }
              else # no more special cases.
                must { string "#{k}:#{v}" }
              end
            end
          end
        end
        # filter :terms, tag_values: params[:tags] if params[:tags].present?
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
