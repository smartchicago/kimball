class ActiveRecord::Base

  def with_user(user)
    self.created_by = user.id if respond_to?(:created_by) && new_record?
    self.updated_by = user.id if respond_to?(:updated_by) && persisted?
    self
  end

end
