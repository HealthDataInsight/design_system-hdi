class Department < ApplicationRecord
  has_many :assistants, dependent: :restrict_with_error

  validates :title, presence: true
end
