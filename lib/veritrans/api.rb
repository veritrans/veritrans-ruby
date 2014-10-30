# Veritrans

module Veritrans
  module Api

    # POST /v2/charge { payment_type: "vtlink" }
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

      post(config.api_host + "/v2/charge", data)
    end

    # POST /v2/{id}/cancel
    def cancel(payment_id, options)
      post(config.api_host + "/v2/#{payment_id}/cancel", options)
    end

    # POST /v2/{id}/approve
    def approve(payment_id, options)
      post(config.api_host + "/v2/#{payment_id}/approve", options)
    end

    # GET /v2/{id}/status
    def status(order_id)
      get(config.api_host + "/v2/#{order_id}/status")
    end

    # POST /v2/capture
    def capture(payment_id, gross_amount, options)
      post(config.api_host + "/v2/capture", options.merge(transaction_id: payment_id, gross_amount: gross_amount))
    end

    # POST /v2/charge { payment_type: "vtlink" }
    def create_vtlink(data, options)
      raise ":server_key option is required" unless options[:server_key]
      data = data.dup
      data[:server_key] = options[:server_key]
      data[:payment_type] = "vtlink"
      post(config.api_host + "/v2/charge", data)
    end

    # DELETE /v2/vtlink/{id}
    def delete_vtlink(id, options)
      delete(config.api_host + "/v2/vtlink/#{id}", options)
    end

  end
end