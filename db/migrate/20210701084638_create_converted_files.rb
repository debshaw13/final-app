class CreateConvertedFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :converted_files do |t|

      t.timestamps
    end
  end
end
