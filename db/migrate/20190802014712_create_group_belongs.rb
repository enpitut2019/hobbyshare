class CreateGroupBelongs < ActiveRecord::Migration[5.2]
  def change
    create_table :group_belongs do |t|
      t.references :group, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
