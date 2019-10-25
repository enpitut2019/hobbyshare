class AdddamieuserIdtToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :dummyuser_id, :integer
  end
end
