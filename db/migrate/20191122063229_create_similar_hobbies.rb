class CreateSimilarHobbies < ActiveRecord::Migration[5.2]
  def change
    create_table :similar_hobbies do |t|
      t.references :hobby, foreign_key: true
      t.integer :next

      t.timestamps
    end
  end
end
