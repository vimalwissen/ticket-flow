class User < ApplicationRecord
  has_secure_password
  enum :role, {
    consumer: "consumer",
    agent: "agent",
    admin: "admin"
  }
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
end