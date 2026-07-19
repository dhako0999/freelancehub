class Client < ApplicationRecord
    belongs_to :user
    
    has_many :projects, dependent: :destroy
  
    validates :name, presence: true
    validates :email,
              presence: true,
              format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :company, presence: true
    validates :phone, presence: true
    validates :notes, presence: true
  end
