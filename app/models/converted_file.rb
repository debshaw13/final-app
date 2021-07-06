class ConvertedFile < ApplicationRecord
  has_one_attached  :file
  belongs_to :ocr_language
  belongs_to :session
end
