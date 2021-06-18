class AddUserIdToUploadedFiles < ActiveRecord::Migration[6.0]
  def change
  	add_reference :uploaded_files, :user, index: true
  end
end
