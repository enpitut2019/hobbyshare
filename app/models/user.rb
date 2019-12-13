class User < ApplicationRecord
  validates :token, presence: true
  validates :opentoken, presence: true
end
