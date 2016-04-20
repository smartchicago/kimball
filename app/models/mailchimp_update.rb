class MailchimpUpdate < ActiveRecord::Base

  after_save  :updatePerson

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

  	end
  end


end
