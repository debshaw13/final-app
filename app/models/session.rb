class Session < ApplicationRecord
  has_many :uploaded_files
  has_many :converted_files

  #validates_numericality_of :count, less_than: 4
end
