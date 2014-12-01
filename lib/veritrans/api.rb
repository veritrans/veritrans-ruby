# Veritrans API methods

require 'uri'

module Veritrans
  module Api

    # POST /v2/charge { payment_type: "vtlink" }
    # Docs http://docs.veritrans.co.id/vtdirect/integration_cc.html#step2
    # Docs http://docs.veritrans.co.id/sandbox/charge.html
    #
    # Example:
    # Veritrans.charge(
    #   payment_type: "credit_card",
    #   credit_card: { token_id: "<token from client>" },
    #   transaction_details: {
    #     order_id: "order_123",
    #     gross_amount: 100_000
    #   }
    # )
    def charge(payment_type, data = nil)
      if payment_type.kind_of?(Hash) && data.nil?
        data = payment_type
        payment_type = nil
      end

      data = data.deep_symbolize_keys if data.respond_to?(:deep_symbolize_keys)

      data[:payment_type] = payment_type if payment_type

      if data.has_key?(:payment_options)
        data[ payment_type.to_sym ] = data.delete(:payment_options)
      end

      # Rename keys:
      # payment     -> transaction_details
      # transaction -> transaction_details
      # items       -> item_details
      # customer    -> customer_details

      data[:transaction_details]  = data.delete(:payment)     if data[:payment]
      data[:transaction_details]  = data.delete(:transaction) if data[:transaction]
      data[:item_details]         = data.delete(:items)       if data[:items]
      data[:customer_details]     = data.delete(:customer)    if data[:customer]

      request_with_logging(:post, config.api_host + "/v2/charge", data)
    end

    # POST /v2/{id}/cancel
    # Docs http://docs.veritrans.co.id/sandbox/other_commands.html
    def cancel(payment_id, options = {})
      request_with_logging(:post, config.api_host + "/v2/#{URI.escape(payment_id)}/cancel", options)
    end

    # POST /v2/{id}/approve
    # Docs http://docs.veritrans.co.id/sandbox/other_commands.html
    def approve(payment_id, options = {})
      request_with_logging(:post, config.api_host + "/v2/#{URI.escape(payment_id)}/approve", options)
    end

    # GET /v2/{id}/status
    # Docs http://docs.veritrans.co.id/sandbox/other_commands.html
    def status(payment_id)
      if !payment_id || payment_id == ""
        raise ArgumentError, "parameter payment_id can not be bank"
      end

      get(config.api_host + "/v2/#{URI.escape(payment_id)}/status")
    end

    # POST /v2/capture
    # Docs http://docs.veritrans.co.id/sandbox/other_features.html
    def capture(payment_id, gross_amount, options = {})
      post(config.api_host + "/v2/capture", options.merge(transaction_id: payment_id, gross_amount: gross_amount))
    end

    # POST /v2/charge { payment_type: "vtlink" }
    def create_vtlink(data)
      data = data.dup
      data[:payment_type] = "vtlink"
      request_with_logging(:post, config.api_host + "/v2/charge", data)
    end

    # DELETE /v2/vtlink/{id}
    def delete_vtlink(id, options)
      request_with_logging(:delete, config.api_host + "/v2/vtlink/#{URI.escape(id)}", options)
    end

  end
end