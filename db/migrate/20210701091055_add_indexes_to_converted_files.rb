class AddIndexesToConvertedFiles < ActiveRecord::Migration[6.0]
  def change
    add_reference :converted_files, :ocr_language, index: true
    add_reference :converted_files, :session, index: true
    add_reference :converted_files, :user, index: true
  end
end
