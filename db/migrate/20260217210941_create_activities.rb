class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.integer :contact_id, null: false
      t.string :kind, null: false
      t.text :body, null: false

      t.timestamps
    end

    add_index :activities, :contact_id
  end
end
