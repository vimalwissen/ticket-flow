class User < ApplicationRecord
  enum :role, [:member, :admin]

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
