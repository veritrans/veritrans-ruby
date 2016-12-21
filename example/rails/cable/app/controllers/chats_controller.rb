class ChatsController < ApplicationController
  def generate_checkout_token
    chat = Chat.find(params[:id])

    order_id = "#{params[:id]}#{SecureRandom.hex(3)}"
    Order.create!(order_id: order_id)

    response = Veritrans.create_widget_token(
      transaction_details: {
        order_id: order_id,
        gross_amount: chat.gross_amount
      }
    )

    token = response.token_id
    render json: {token: token}
  end
end
