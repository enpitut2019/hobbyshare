class AddColumnAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :is_temp, :boolean, default: false, null: false
  end
end
