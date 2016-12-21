class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.string :transaction_status
      t.string :price

      t.timestamps
    end
  end
end
