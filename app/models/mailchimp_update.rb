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

  def updatePerson
  	Rails.logger.info("[ MailchimpUpdate#updatePerson ] email = #{email} update_type = #{update_type}")

  	Person.where(email_address: email).find_each do |person|
  	  if ( update_type == 'unsubscribe' )
  	  	@tag = Tag.find_or_initialize_by(name: update_type)
      	@tagging = Tagging.new(taggable_type: "Person", taggable_id: person.id, tag: @tag)
      	@tagging.save

      	@comment = Comment.new
      	@comment.content = "MailChimp Webhook Update: #{update_type} because reason = #{reason} at #{fired_at}"
      	@comment.commentable_type = "Person"
      	@comment.commentable_id = person.id
      	@comment.save
  	  end


        content = "MailChimp Webhook Update: #{update_type} because reason = #{reason} at #{fired_at}"

        @comment = Comment.create(content: content,
                               commentable_type: 'Person',
                               commentable_id: person.id)
      end
    end
  end

end
