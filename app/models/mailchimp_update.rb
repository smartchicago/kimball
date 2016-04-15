# == Schema Information
#
# Table name: mailchimp_updates
#
#  id          :integer          not null, primary key
#  raw_content :text(65535)
#  email       :string(255)
#  update_type :string(255)
#  reason      :string(255)
#  fired_at    :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class MailchimpUpdate < ActiveRecord::Base
  scope :latest, -> { order('fired_at DESC') }

  self.per_page = 15

  after_save :update_person

  def update_person
    Person.where(email_address: email).find_each do |person|
      case update_type
      when'unsubscribe'
        @tagging = Tagging.create(taggable_type: 'Person', taggable_id: person.id, tag: Tag.find_or_initialize_by(name: update_type))

        content = "MailChimp Webhook Update: #{update_type} because reason = #{reason} at #{fired_at}"

        @comment = Comment.create(content: content,
                               commentable_type: 'Person',
                               commentable_id: person.id)
      end
    end
  end

end
