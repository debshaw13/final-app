class UploadedFile < ApplicationRecord
  has_one_attached  :file
  belongs_to :ocr_language
  belongs_to :session

  validates :file, :presence => true  
end
