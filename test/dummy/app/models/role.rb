class Role < ApplicationRecord
  has_many :assistants, dependent: :restrict_with_error

  validates :title, presence: true
end
