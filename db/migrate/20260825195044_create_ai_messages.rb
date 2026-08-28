class CreateAiMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_messages do |t|
      t.references :ai_conversation, null: false, foreign_key: true
      t.string :role
      t.text :content

      t.timestamps
    end
  end
end
