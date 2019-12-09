class User < ApplicationRecord
  validates :token, presence: true
end
