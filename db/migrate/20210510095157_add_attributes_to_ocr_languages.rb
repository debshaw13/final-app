class AddAttributesToOcrLanguages < ActiveRecord::Migration[6.0]
  def change
  	add_column :ocr_languages, :code, :string 
  	add_column :ocr_languages, :language, :string
  end
end
