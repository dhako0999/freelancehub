class Client < ApplicationRecord
    has_many  :projects, dependent: :destroy
    validates :name, presence: true
    validates :email, presence: true
    validates :company, presence: true
    validates :phone, presence: true
    validates :notes, presence: true
end
