class RemovegroupPasswordFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :group_password
  end
end
