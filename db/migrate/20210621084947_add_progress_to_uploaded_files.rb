class AddProgressToUploadedFiles < ActiveRecord::Migration[6.0]
  def change
    add_column :uploaded_files, :progress, :integer
  end
end
