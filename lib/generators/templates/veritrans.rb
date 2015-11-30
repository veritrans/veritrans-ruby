Veritrans.setup do
  config.load_config Rails.root.join("config/veritrans.yml"), Rails.env

  # Or set it manually...
  # config.server_key = ""
  # config.client_key = ""
  # config.api_host = ""

  # Veritrans::Events is rack application to handle http notifications from Veritrans
  # To enable it, add in config/routes.rb
  # mount Veritrans::Events.new => '/vt_events'

  # All possible events:
  #
  # * payment.success     == ['authorize', 'capture', 'settlement']
  # * payment.failed      == ['deny', 'canel', 'expire']
  # * payment.challenge   # when payment.froud_status == 'challenge'
  #
  # * payment.authorize
  # * payment.capture
  # * payment.settlement
  # * payment.deny
  # * payment.canel
  # * payment.expire

  # events.subscribe 'payment.success' do |payment|
  #   payment.mark_paid!
  # end
  # 
  # events.subscribe 'payment.failed' do |payment|
  #   payment.mark_failed!
  # end
  # 
  # events.subscribe 'payment.challenge' do |payment|
  #   payment.mark_challenge!
  # end
  # 
  # events.subscribe /.+/ do |payment, event_name|
  #   p "Event: #{event_name}"
  #   p payment
  # end

end
