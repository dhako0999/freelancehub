class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.references :client, null: false, foreign_key: true
      t.string :name
      t.string :status
      t.date :start_date
      t.date :deadline
      t.decimal :budget
      t.text :description

      t.timestamps
    end
  end
end
