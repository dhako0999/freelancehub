class CreateClients < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :email
      t.string :company
      t.string :phone
      t.string :industry
      t.string :service_type
      t.string :status
      t.string :website
      t.text :notes

      t.timestamps
    end
  end
end
