class CreateSubmissions < ActiveRecord::Migration

  def change
    create_table :submissions do |t|
      t.text    :raw_content
      t.integer :person_id
      t.string  :ip_addr
      t.string  :entry_id
      t.text    :form_structure
      t.text    :field_structure
      t.timestamps
    end
  end

end
