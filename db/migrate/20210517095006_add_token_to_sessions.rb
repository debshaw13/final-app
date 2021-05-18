class AddTokenToSessions < ActiveRecord::Migration[6.0]
  def change
  	add_column :sessions, :token, :string
  end
end
