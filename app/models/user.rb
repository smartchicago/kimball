class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable,  :validatable, :stretches => 10

  def active_for_authentication? 
    if super && approved?
      true
    else
      Rails.logger.warn("[SEC] User #{email} is not approved but attempted to authenticate.")
      false
    end
  end
  
  def inactive_message 
    if !approved? 
      :not_approved 
    else 
      super # Use whatever other message 
    end 
  end
  
  def approve!
    update_attributes(approved: true)
    Rails.logger.info("Approved user #{email}")
  end

  def unapprove!
    update_attributes(approved: false)
    Rails.logger.info("Unapproved user #{email}")
  end
  
end
