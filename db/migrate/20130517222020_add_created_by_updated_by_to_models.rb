class AddCreatedByUpdatedByToModels < ActiveRecord::Migration

  def change
    add_column :applications, :created_by, :integer
    add_column :applications, :updated_by, :integer

    add_column :comments, :created_by, :integer

    add_column :events, :created_by, :integer
    add_column :events, :updated_by, :integer

    add_column :programs, :created_by, :integer
    add_column :programs, :updated_by, :integer

    add_column :reservations, :updated_by, :integer
  end

end
