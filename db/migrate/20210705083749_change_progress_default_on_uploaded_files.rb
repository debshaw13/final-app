class ChangeProgressDefaultOnUploadedFiles < ActiveRecord::Migration[6.0]
  def change
    change_column_default :uploaded_files, :progress, 10
  end
end
