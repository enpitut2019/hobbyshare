class AddReferencesToSimilarHobby < ActiveRecord::Migration[5.2]
  def change
    add_reference :similar_hobbies, :user, foreign_key: true
  end
end
