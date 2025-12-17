class Comment < ApplicationRecord
  belongs_to :ticket

  validates :author, presence: true
  validates :content, presence: true , length: { maximum: 300 }
end
