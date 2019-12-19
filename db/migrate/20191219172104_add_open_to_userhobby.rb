class AddOpenToUserhobby < ActiveRecord::Migration[5.2]
  def change
    add_column :user_hobbies, :open, :boolean, default: false, null: false
  end
end
