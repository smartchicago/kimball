class AddFormIdAndSubmissionTypeToSubmissions < ActiveRecord::Migration
  def change
  	add_column :submissions, :form_id, :string
  	add_column :submissions, :form_type, :integer
  end
end
