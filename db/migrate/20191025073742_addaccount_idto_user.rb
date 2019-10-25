class AddaccountIdtoUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :account_id, :integer
    add_column :users, :group_id, :integer
  end
end
