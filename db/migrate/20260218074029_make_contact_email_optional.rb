class MakeContactEmailOptional < ActiveRecord::Migration[8.1]
  def change
    change_column_null :contacts, :email, true
    remove_index :contacts, :email, if_exists: true
  end
end
