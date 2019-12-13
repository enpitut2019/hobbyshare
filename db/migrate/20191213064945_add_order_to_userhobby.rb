class AddOrderToUserhobby < ActiveRecord::Migration[5.2]
  def change
    add_column :user_hobbies, :order, :integer, default: 0
  end
end
