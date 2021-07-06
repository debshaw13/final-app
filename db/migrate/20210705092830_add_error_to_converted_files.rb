class AddErrorToConvertedFiles < ActiveRecord::Migration[6.0]
  def change
    add_column :converted_files, :error, :string 
  end
end
