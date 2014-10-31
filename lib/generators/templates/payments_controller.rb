class PaymentsController < ApplicationController

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

end