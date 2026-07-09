class Project < ApplicationRecord
  belongs_to :client
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
  validates :status, presence: true
end


