class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :hobby1
      t.string :hobby2
      t.string :hobby3

      t.timestamps
    end
  end
end
