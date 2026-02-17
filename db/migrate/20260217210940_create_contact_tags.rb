class CreateContactTags < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_tags do |t|
      t.integer :contact_id, null: false
      t.integer :tag_id, null: false

      t.timestamps
    end

    add_index :contact_tags, [ :contact_id, :tag_id ], unique: true
    add_index :contact_tags, :tag_id
  end
end
