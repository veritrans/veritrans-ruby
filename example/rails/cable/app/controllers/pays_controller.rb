class PaysController < ApplicationController
  skip_before_action :verify_authenticity_token

  def notify
    transaction_status = params["transaction_status"]
    fraud_status = params["fraud_status"]

    if transaction_status == "capture" && fraud_status == "accept"
      Order.find_by_order_id(params["order_id"]).update_attributes!(
        transaction_status: transaction_status
      )
    end

    render text: "OK"
  end

  def finish
    redirect_to rooms_path
  end

  def unfinish
    redirect_to rooms_path
  end

  def error
    redirect_to rooms_path
  end
end
