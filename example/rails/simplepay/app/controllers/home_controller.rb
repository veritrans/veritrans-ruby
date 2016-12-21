class HomeController < ApplicationController
  def index
    @order = Order.create!(
      price: (rand.round(6) * 1000).to_i * 1000
    )

    response = Veritrans.create_widget_token(
      transaction_details: {
        order_id: @order.id,
        gross_amount: @order.price
      }
    )

    @token = response.token_id
  end
end
