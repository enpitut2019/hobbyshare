class ChangeColumnUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :account_id
    remove_column :users, :group_id
    add_reference :users, :account, foreign_key: true
    add_reference :users, :group, foreign_key: true
  end
end
