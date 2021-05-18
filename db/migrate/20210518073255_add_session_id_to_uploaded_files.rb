class AddSessionIdToUploadedFiles < ActiveRecord::Migration[6.0]
  def change
  	add_reference :uploaded_files, :session, index: true
  end
end
