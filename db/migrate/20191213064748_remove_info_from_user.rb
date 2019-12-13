class RemoveInfoFromUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :info, :string
  end
end
