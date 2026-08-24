class Project < ApplicationRecord
  include AcceptableFiles
  
  belongs_to :client
  
  has_many :tasks, dependent: :destroy
  has_many_attached :files

  validates :name, presence: true
  validates :status, presence: true

end
