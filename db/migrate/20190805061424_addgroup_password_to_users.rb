class AddgroupPasswordToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :group_password, :string
  end
end
