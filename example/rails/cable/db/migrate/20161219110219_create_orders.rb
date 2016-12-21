class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.string :order_id
      t.string :payment_type
      t.string :transaction_status

      t.timestamps
    end
  end
end
