class CreateOcrLanguages < ActiveRecord::Migration[6.0]
  def change
    create_table :ocr_languages do |t|

      t.timestamps
    end
  end
end
