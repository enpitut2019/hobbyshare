class AddSimilarToUserHobby < ActiveRecord::Migration[5.2]
  def change
    add_reference :user_hobbies, :similar_hobbies, foreign_key: true
  end
end
