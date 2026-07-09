class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title
      t.string :status
      t.date :due_date
      t.text :description

      t.timestamps
    end
  end
end
