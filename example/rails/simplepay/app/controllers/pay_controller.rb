class PayController < ApplicationController
  def notify
    Order.find_by_id(params["order_id"]).update_attributes!(
      transaction_status: params["transaction_status"}]
    )

    # must return status 200
    render text: "ACK"
  end
end
