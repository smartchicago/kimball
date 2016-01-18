class AddingRelationshipBetweenProgramsAndApplications < ActiveRecord::Migration

  def change
    add_column :applications, :program_id, :integer
  end

end
