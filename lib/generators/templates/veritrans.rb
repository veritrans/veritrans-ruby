Veritrans.setup do
  config.load_config Rails.root.join("config/veritrans.yml")

  # Or set it manually...
  # config.server_key = ""
  # config.client_key = ""
  # config.api_host = ""

=begin
  # Not implemented yet
  events.subscribe 'payment.success' do |event|
    # Define subscriber behavior based on the event object
    event.class       #=> Veritrans::Event
    event.type        #=> "payment.success"
    event.data.object #=> #<Veritrans::Result:0x3fcb34c115f8>
  end

  events.subscribe 'payment.failed' do |event|
    # Define subscriber behavior based on the event object
    event.class       #=> Veritrans::Event
    event.type        #=> "payment.failed"
    event.data.object #=> #<Veritrans::Result:0x3fcb34c115f8>
  end

  events.subscribe 'payment.challenge' do |event|
    # Define subscriber behavior based on the event object
    event.class       #=> Veritrans::Event
    event.type        #=> "payment.challenge"
    event.data.object #=> #<Veritrans::Result:0x3fcb34c115f8>
  end

=end

end
