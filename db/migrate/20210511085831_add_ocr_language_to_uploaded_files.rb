class AddOcrLanguageToUploadedFiles < ActiveRecord::Migration[6.0]
  def change
    add_reference :uploaded_files, :ocr_language, index: true
  end
end
