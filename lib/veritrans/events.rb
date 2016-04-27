# Rack based event notification callback processor
#
# Usage:
#
#     Rails.application.routes.draw do
#       ...
#       mount Veritrans::Events.new => '/vt_events'
#     end
#     
#     Veritrans.events.subscribe('payment.success') do |payment|
#       payment.mark_paid!(payment.masked_card)
#     end
#

# All possible events:
#
# * payment.success     == ['authorize', 'capture', 'settlement']
# * payment.failed      == ['deny', 'cancel', 'expire']
# * payment.challenge   # when payment.fraud_status == 'challenge'
#
# * payment.authorize
# * payment.capture
# * payment.settlement
# * payment.deny
# * payment.cancel
# * payment.expire
#
# * error

# For sinatra you can use Rack::URLMap
#
#     run Rack::URLMap.new("/" => MyApp.new, "/payment_events" => Veritrans::Events.new)
#

class Veritrans
  class Events

    # This is rack application
    def call(env)
      Veritrans.logger.info "Receive notification callback"

      post_body = env["rack.input"].read
      env["rack.input"].rewind
      request_data = Veritrans.decode_notification_json(post_body)

      Veritrans.file_logger.info("Callback for order: " +
        "#{request_data['order_id']} #{request_data['transaction_status']}\n" +
        post_body + "\n"
      )

      verified_data = Veritrans.status(request_data['transaction_id'])

      if verified_data.status_code != 404
        #puts "--- Transaction callback ---"
        #puts "Payment:        #{verified_data.data[:order_id]}"
        #puts "Payment type:   #{verified_data.data[:payment_type]}"
        #puts "Payment status: #{verified_data.data[:transaction_status]}"
        #puts "Fraud status:   #{verified_data.data[:fraud_status]}" if verified_data.data[:fraud_status]
        #puts "Payment amount: #{verified_data.data[:gross_amount]}"
        #puts "--- Transaction callback ---"

        event_name = verified_data.data[:transaction_status]
        if verified_data.data[:fraud_status] == 'challenge'
          event_name = 'challenge'
        end

        Veritrans::Events.dispatch("payment.#{event_name}", verified_data)

        if %w{capture authorize settlement}.include?(event_name)
          Veritrans::Events.dispatch("payment.success", verified_data)
        elsif event_name != 'challenge'
          Veritrans::Events.dispatch("payment.failed", verified_data)
        end

        return send_text("ok", 200)
      else
        Veritrans::Events.dispatch("error", request_data)
        Veritrans.file_logger.info("Callback verification failed:" +
          "#{request_data['order_id']} #{request_data['transaction_status']}}\n" +
          verified_data.body + "\n"
        )
        return send_text("Can not verify payment via Payment API: #{verified_data.status_message}", 404)
      end

    rescue Object => error
      Veritrans.file_logger.info("Callback proccesing failed. \n" +
        "RAW_POST_DATA: #{env["rack.input"].read}\n" +
        error.message +
        error.backtrace.join("\n") + "\n"
      )
      Veritrans::Events.dispatch("error", verified_data || request_data || post_body)
      return send_text("Server error:\n#{error.message}", 500)
    end

    def send_text(body, status = 200)
      [status, {"Content-Type" => "text/html"}, [body]]
    end

    # processing events

    class << self
      attr_accessor :listeners

      def subscribe(*event_types, &handler)
        @listeners ||= []
        event_types.each do |event_type|
          @listeners << [event_type, handler]
        end
      end

      def dispatch(new_event, event_data)
        @listeners.each do |pair|
          event_type, handler = *pair

          if event_type.is_a?(String) && event_type == new_event
            handler.call(event_data)
          elsif event_type.is_a?(Regexp) && event_type =~ new_event
            handler.call(event_data, new_event)
          end
        end
      end

    end
  end
end