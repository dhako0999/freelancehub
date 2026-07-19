class MakeUserRequiredOnClients < ActiveRecord::Migration[8.1]
  def change
    change_column_null :clients, :user_id, false
  end
end
