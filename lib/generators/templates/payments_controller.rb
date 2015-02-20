class PaymentsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:receive_webhook]

  def new
    @payment = make_payment
  end

  def create
    @payment = make_payment

    if params[:type] == "vtweb"
      @result = Veritrans.charge(
        payment_type: "VTWEB",
        transaction_details: {
          order_id: @payment.order_id,
          gross_amount: @payment.amount
        }
      )
      redirect_to @result.redirect_url
      return
    end

    @result = Veritrans.charge(
      payment_type: "credit_card",
      credit_card: { token_id: params[:payment][:token_id] },
      transaction_details: {
        order_id: @payment.order_id,
        gross_amount: params[:payment][:amount].presence || @payment.amount
      }
    )
  end

  def receive_webhook
    post_body = request.body.read

    Veritrans.file_logger.info("Callback for order: " +
      "#{params[:order_id]} #{params[:transaction_status]}\n" +
      post_body + "\n"
    )

    verified_data = Veritrans.status(params["transaction_id"])

    if verified_data.status_code != 404
      puts "--- Transaction callback ---"
      puts "Payment:        #{verified_data.data[:order_id]}"
      puts "Payment type:   #{verified_data.data[:payment_type]}"
      puts "Payment status: #{verified_data.data[:transaction_status]}"
      puts "Fraud status:   #{verified_data.data[:fraud_status]}" if verified_data.data[:fraud_status]
      puts "Payment amount: #{verified_data.data[:gross_amount]}"
      puts "--- Transaction callback ---"

      render text: "ok"
    else
      Veritrans.file_logger.info("Callback verification failed for order: " +
        "#{params[:order_id]} #{params[:transaction_status]}}\n" +
        verified_data.body + "\n"
      )

      render text: "ok", :status => :not_found
    end

  end

  private
  def make_payment
    @paymentKlass = Struct.new("Payment", :amount, :token_id, :order_id, :credit_card_secure) do
      extend ActiveModel::Naming
      include ActiveModel::Conversion

      def persisted?; false; end

      def self.name
        "Payment"
      end
    end

    @paymentKlass.new(100_000, '', "testing-#{rand.round(4)}-#{Time.now.to_i}", false)
  end

end