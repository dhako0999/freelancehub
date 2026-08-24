module AcceptableFiles
    extend ActiveSupport::Concern
  
    ALLOWED_FILE_TYPES = [
      "application/pdf",
      "application/msword",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      "text/plain",
      "image/png",
      "image/jpeg"
    ].freeze
  
    MAX_FILE_SIZE = 10.megabytes
  
    included do
      validate :acceptable_files
    end
  
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