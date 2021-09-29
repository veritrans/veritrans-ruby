# Veritrans ruby library

Veritrans gem is the library that will help you to integrate seamlessly with
Midtrans (formerly known as Veritrans Indonesia).

[![Gem Version](https://badge.fury.io/rb/veritrans.svg)](http://badge.fury.io/rb/veritrans)
[![Build Status](https://travis-ci.org/veritrans/veritrans-ruby.svg?branch=master)](https://travis-ci.org/veritrans/veritrans-ruby)

To see it in action, we have made example:

1. Sinatra, which demonstrate in as succint code as possible. Please [have a look here](https://github.com/veritrans/veritrans-ruby/tree/master/example/sinatra)

## How to use

### Add gem veritrans to Gemfile

```ruby
gem 'veritrans'
```
```ruby
gem install veritrans
```

    bundle install

### General setting
Create instance of Midtrans client

```ruby
require 'veritrans'

mt_client = Midtrans.new(
    server_key: "your server key",
    client_key: "your client key",
    api_host: "https://api.sandbox.midtrans.com", # default
    http_options: { }, # optional
    logger: Logger.new(STDOUT), # optional
    file_logger: Logger.new(STDOUT), # optional
  )

mt_client.status("order-id-123456")
```

also can set one by one

```ruby
Midtrans.config.server_key = "your server key"
Midtrans.config.client_key = "your client key"
Midtrans.config.api_host = "https://api.sandbox.midtrans.com"
```

### Override Notification URL

You can opt to change or add custom notification urls on every transaction. It can be achieved by adding additional HTTP headers into charge request.
```ruby
# Add new notification url(s) alongside the settings on Midtrans Dashboard Portal (MAP)
$append_notif_url = "https://example.com/test1,https://example.com/test2"
# Use new notification url(s) disregarding the settings on Midtrans Dashboard Portal (MAP)
$override_notif_url = "https://example.com/test1"
```

[More details](https://api-docs.midtrans.com/#override-notification-url)
> **Note:** When both `appendNotifUrl` and `overrideNotifUrl` are used together then only `overrideNotifUrl` will be used.

> Both header can only receive up to maximum of **3 urls**.

### Idempotency-Key
You can opt to add idempotency key on charge transaction. It can be achieved by adding additional HTTP headers into charge request.
Is a unique value that is put on header on API request. Midtrans API accept Idempotency-Key on header to safely handle retry request
without performing the same operation twice. This is helpful for cases where merchant didn't receive the response because of network issue or other unexpected error.
```ruby
$idempotency_key = "Unique-ID"
```
[More details](http://api-docs.midtrans.com/#idempotent-requests)


## STEP 1: Process credit cards

### Snap Pop-up

Customizable payment popup will appear on your web/app (no redirection)

First, generate token in the back end provided with enough details as necessary
and as detailed as you wish to.

```ruby
result = Veritrans.create_widget_token(
  transaction_details: {
    order_id: generate_order_id,
    gross_amount: 100000
  }
)
@token = result.token
```

Initialize Snap JS when customer click pay button

```html
<html>
  <body>
  <p>
    <label>Snap Token</label>
    <input type="text" id="token" value="<%= @token %>" readonly size="50">
  </p>
  <button id="pay-button">Pay</button>
  <pre><div id="result-json">JSON result will appear here after payment:<br></div></pre>

  <!-- TODO: Remove ".sandbox" from script src URL for production environment. Also input your client key in "data-client-key" -->
  <script src="https://app.sandbox.midtrans.com/snap/snap.js" data-client-key="SB-Mid-client-ArNfhrh7st9bQKmz"></script>
  <script type="text/javascript">
      document.getElementById('pay-button').onclick = function(){
          // SnapToken acquired from previous step
          snap.pay('<%= @token %>', {
              // Optional
              onSuccess: function(result){
                  /* You may add your own js here, this is just example */ document.getElementById('result-json').innerHTML += JSON.stringify(result, null, 2);
              },
              // Optional
              onPending: function(result){
                  /* You may add your own js here, this is just example */ document.getElementById('result-json').innerHTML += JSON.stringify(result, null, 2);
              },
              // Optional
              onError: function(result){
                  /* You may add your own js here, this is just example */ document.getElementById('result-json').innerHTML += JSON.stringify(result, null, 2);
              }
          });
      };
  </script>
  </body>
```

### Snap Redirect

This will result in redirect_url, you can redirect customer to the url, payment page is securely hosted by Midtrans.

```ruby
result = Veritrans.create_widget_token(
  transaction_details: {
    order_id: generate_order_id,
    gross_amount: 100000
  }
)
@redirecturl = result.redirect_url
```

> This is similar feature as old VT-Web

#### VT-Web

> !!! WARNING NOTE: VT-Web is deprecated, please use [Snap](#Snap Pop-up) instead, it has better previous VT-Web feature and many more improvements, including redirect_url.

### VT-Direct / Core API

It's little more complicated, because credit_card is sensitive data,
you need put credit card number in our safe storage first using `midtrans.min.js` library, then send received token to with other payment details.

We don't want you to send credit card number to your server, especially for websites not using https.


```html
<script id="midtrans-script" type="text/javascript"
src="https://api.midtrans.com/v2/assets/js/midtrans-new-3ds.min.js"
data-environment="sandbox"
data-client-key="<INSERT YOUR CLIENT KEY HERE>"></script>
```

For sinatra:

```html
<form action="/coreapi" method="POST" id="payment-form">
  <fieldset>
    <legend>Checkout</legend>
    <small><strong>Field that may be presented to customer:</strong></small>
    <p>
      <label>Card Number</label>
      <input class="card-number" name="card-number" value="4811 1111 1111 1114" size="23" type="text" autocomplete="off" />
    </p>
    <p>
      <label>Expiration (MM/YYYY)</label>
      <input class="card-expiry-month" name="card-expiry-month" value="12" placeholder="MM" size="2" type="text" />
      <span> / </span>
      <input class="card-expiry-year" name="card-expiry-year" value="2025" placeholder="YYYY" size="4" type="text" />
    </p>
    <p>
      <label>CVV</label>
      <input class="card-cvv" name="card-cvv" value="123" size="4" type="password" autocomplete="off" />
    </p>
    <p>
      <label>Save credit card</label>
      <input type="checkbox" id="save_cc" name="save_cc" value="true">
    </p>
    <small><strong>Fields that shouldn't be presented to the customer:</strong></small>
    <p>
      <label>3D Secure</label>
      <input type="checkbox" id="secure" name="secure" value="true" checked>
    </p>
    <input id="token_id" name="token_id" type="hidden" />
    <button class="submit-button" type="submit">Submit Payment</button>
  </fieldset>
</form>
```

#### Sending "get-token" request:

Please refer to [this file](example/sinatra/index.erb)


On a server side:

```ruby
@result = Veritrans.charge(
  payment_type: "credit_card",
  credit_card: {
    token_id: params[:token_id],
    authentication: params[:secure]
  },
  transaction_details: {
    order_id: generate_order_id,
    gross_amount: 20000
  })
```

## STEP 2: Process non credit cards payment

We provide many payment channels to accept payment, but the API call is almost the same.

For Snap / VT-Web in only one request, payment page will display all available payment options.

For Core API / VT-Direct you have to specify payment method (without get token step, credit card token required only for credit card transactions).

```ruby
@result = Veritrans.charge(
  payment_type: "bank_transfer",
  bank_transfer: { bank: 'permata' },
  transaction_details: {
    order_id: @payment.order_id,
    gross_amount: @payment.amount
  }
)
puts "Please transfer fund to account no. #{@result.permata_va_number} in bank Permata"
```

See [our documentation](https://api-docs.midtrans.com/#charge-features) for other available options.


## STEP 3: Receive notification callback

For every transaction success and failed we will send you HTTP POST notification (aka webhook)

First you should set callback url in our dashboard https://dashboard.sandbox.midtrans.com/settings/vtweb_configuration

For testing in development phase please read our [Testing webhooks tutorial](https://github.com/veritrans/veritrans-ruby/blob/master/testing_webhooks.md)


For rails:

```ruby
# config/routes.rb
match "/payments/receive_webhook" => "payments#receive_webhook", via: [:post]

# app/controllers/payments_controller.rb
def receive_webhook
  post_body = request.body.read
  callback_params = Veritrans.decode_notification_json(post_body)

  verified_data = Veritrans.status(callback_params['transaction_id'])

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
    render text: "ok", :status => :not_found
  end
end
```

----

#### Veritrans::Events

Other option to handle callbacks is our rack-based handler

```ruby
# config/routes.rb
mount Veritrans::Events.new => '/vt_events'

# config/initalizers/veritrans.rb
Veritrans.setup do
  config.server_key = "..."
  config.client_key = "..."

  events.subscribe('payment.success') do |payment|
    # payment variable is hash with params recieved from Veritrans
    # assuming you have model Order in your project
    Order.find_by(order_id: payment.order_id).mark_paid!(payment.masked_card)
  end

  events.subscribe('payment.failed', 'payment.challenge') do |payment|
    # payment variable is hash with params recieved from Veritrans
    # assuming you have model Order in your project
    Order.find_by(order_id: payment.order_id) ...
  end
end
```

#### Logging

By default gem veritrans will show information via rails' logger. And in addition save important information to `RAILS_APP/log/veritrans.log`

It's configurable.

```ruby
Veritrans.logger = Rails.logger
Veritrans.file_logger = Logger.new("/my/important_logs/veritrans.log")
```

`Veritrans.file_logger` save information about:

* "charge", "cancel", "approve" api calls
* Validation errors for "charge", "cancel", "approve"
* Received http notifications
* Errors and exception while processing http notifications

----



#### Get help

* [Veritrans gem reference](https://github.com/veritrans/veritrans-ruby/blob/master/api_reference.md)
* [Midtrans login](https://account.midtrans.com/login)
* [Midtrans registration](https://account.midtrans.com/register)
* [Midtrans documentation](http://docs.midtrans.com)
* Technical support [support@midtrans.com](mailto:support@midtrans.com)
