class Group < ApplicationRecord
  validates :token, presence: true
end
