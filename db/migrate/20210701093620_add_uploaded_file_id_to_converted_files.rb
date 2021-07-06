class AddUploadedFileIdToConvertedFiles < ActiveRecord::Migration[6.0]
  def change
    add_column :converted_files, :uploaded_file_id, :integer 
  end
end
