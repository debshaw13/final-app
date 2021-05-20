class AddCountToSessions < ActiveRecord::Migration[6.0]
  def change
  	add_column :sessions, :count, :integer, default: 0
  end
end
