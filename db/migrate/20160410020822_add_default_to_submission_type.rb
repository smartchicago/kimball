class AddDefaultToSubmissionType < ActiveRecord::Migration
  def change
  	change_column :submissions, :form_type, :integer, :default => 0
  end
end