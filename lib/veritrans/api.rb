# Veritrans API methods

require 'uri'

class Veritrans
  module Api

    # POST /v2/charge { payment_type: "credit_card" }
    # Docs https://api-docs.midtrans.com/#charge-features
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

    # POST https://app.sandbox.midtrans.com/snap/v1/transactions
    def create_snap_token(options = {})
      result = request_with_logging(:post, config.api_host.sub('//api.', '//app.') + "/snap/v1/transactions", options)
      Veritrans::SnapResult.new(result.response, result.url, result.request_options, result.time)
    end

    alias_method :create_widget_token, :create_snap_token
    alias_method :create_snap_redirect_url, :create_snap_token

    # POST /v2/{id}/cancel
    # Docs https://api-docs.midtrans.com/#cancel-transaction
    def cancel(payment_id, options = {})
      if !payment_id || payment_id.to_s == ""
        raise ArgumentError, "parameter payment_id can not be blank (got #{payment_id.class} : #{payment_id.inspect})"
      end

      request_with_logging(:post, config.api_host + "/v2/#{URI.escape(payment_id)}/cancel", options)
    end

    # POST /v2/{id}/approve
    # Docs https://api-docs.midtrans.com/#approve-transaction
    def approve(payment_id, options = {})
      if !payment_id || payment_id.to_s == ""
        raise ArgumentError, "parameter payment_id can not be blank (got #{payment_id.class} : #{payment_id.inspect})"
      end

      request_with_logging(:post, config.api_host + "/v2/#{URI.escape(payment_id)}/approve", options)
    end

    # GET /v2/{id}/status
    # Docs https://api-docs.midtrans.com/#get-status-transaction
    def status(payment_id)
      if !payment_id || payment_id.to_s == ""
        raise ArgumentError, "parameter payment_id can not be blank (got #{payment_id.class} : #{payment_id.inspect})"
      end

      get(config.api_host + "/v2/#{URI.escape(payment_id)}/status")
    end

    # POST /v2/capture
    # Docs https://api-docs.midtrans.com/#capture-transaction
    def capture(payment_id, gross_amount, options = {})
      if !payment_id || payment_id.to_s == ""
        raise ArgumentError, "parameter payment_id can not be blank (got #{payment_id.class} : #{payment_id.inspect})"
      end

      post(config.api_host + "/v2/capture", options.merge(transaction_id: payment_id, gross_amount: gross_amount))
    end

    # POST /v2/{id}/expire
    # Docs https://api-docs.midtrans.com/#expire-transaction
    def expire(payment_id)
      if !payment_id || payment_id.to_s == ""
        raise ArgumentError, "parameter payment_id can not be blank (got #{payment_id.class} : #{payment_id.inspect})"
      end

      request_with_logging(:post, config.api_host + "/v2/#{URI.escape(payment_id)}/expire", nil)
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

    # GET /v2/point_inquiry/{token_id}
    def inquiry_points(token_id)
      if token_id == nil || token_id.to_s == ""
        raise ArgumentError, "parameter token_id can not be bank"
      end

      request_with_logging(:get, config.api_host + "/v2/point_inquiry/#{token_id}", {})
    end
    alias_method :point_inquiry, :inquiry_points

  end
end
