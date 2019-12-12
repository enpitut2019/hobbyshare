class AddTokenUsersAndGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :token, :string
    add_column :users, :token, :string
  end
end
