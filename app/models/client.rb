class Client < ApplicationRecord
  ALLOWED_FILE_TYPES = [
    "application/pdf",
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "text/plain",
    "image/png",
    "image/jpeg"
  ].freeze

  MAX_FILE_SIZE = 10.megabytes

  belongs_to :user

  has_many :projects, dependent: :destroy
  has_many_attached :files

  validates :name, presence: true
  validates :email,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :company, presence: true
  validates :phone, presence: true
  validates :notes, presence: true

  validate :acceptable_files

  private

  def acceptable_files
    files.each do |file|
      validate_file_size(file)
      validate_file_type(file)
    end
  end

  def validate_file_type(file)
    return if ALLOWED_FILE_TYPES.include?(file.content_type)

    errors.add(
      :files,
      "#{file.filename} must be a PDF, Word document, text file, PNG, or JPEG"
    )
  end

  def validate_file_size(file)
    return if file.byte_size <= MAX_FILE_SIZE

    errors.add(
      :files,
      "#{file.filename} must be smaller than 10 MB"
    )
  end
end
