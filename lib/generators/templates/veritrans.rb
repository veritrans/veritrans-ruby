Veritrans.setup do
  config.load_config Rails.root.join("config/veritrans.yml"), Rails.env

  # Or set it manually...
  # config.server_key = ""
  # config.client_key = ""
  # config.api_host = ""

  # Veritrans::Events is rack application to handle http notifications from Veritrans
  # To enable it, add in config/routes.rb
  #
  #   mount Veritrans::Events.new => '/vt_events'
  #
  # All possible events:
  #
  # 'payment.success'     == ['authorize', 'capture', 'settlement']
  # 'payment.failed'      == ['deny', 'cancel', 'expire']
  # 'payment.challenge'   # when payment.fraud_status == 'challenge'
  #
  # 'payment.authorize'
  # 'payment.capture'
  # 'payment.settlement'
  # 'payment.deny'
  # 'payment.cancel'
  # 'payment.expire'

  # events.subscribe 'payment.success' do |payment|
  #   payment is instance of Veritrans::Result
  #   puts "Payment #{payment.data[:order_id]} is successful"
  # end
  #
  # events.subscribe 'payment.failed' do |payment|
  #   puts "Payment #{payment.data[:order_id]} is failed"
  # end
  #
  # events.subscribe 'payment.challenge' do |payment|
  #   puts "Payment #{payment.data[:order_id]} chellenged by fraud system"
  #   payment.mark_challenge!
  # end
  #
  # events.subscribe /.+/ do |payment, event_name|
  #   puts "Payment #{payment.data[:order_id]} has status #{payment.data[:transaction_status]}"
  #   p payment
  # end

end
