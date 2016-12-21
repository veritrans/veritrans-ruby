class CreateChats < ActiveRecord::Migration[5.0]
  def change
    create_table :chats do |t|
      t.string :sender_id, null: false
      t.text :text, null: false

      t.timestamps
    end
  end
end
