class AddOpentokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :opentoken, :string
  end
end
