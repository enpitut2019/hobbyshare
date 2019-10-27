class ChangeColumnAccounts < ActiveRecord::Migration[5.2]
  def change
    remove_column :accounts, :dummyuser_id
    add_reference :accounts, :user, foreign_key: true
  end
end
