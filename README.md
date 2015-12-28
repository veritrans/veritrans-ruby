# Veritrans ruby library

[![Gem Version](https://badge.fury.io/rb/veritrans.svg)](http://badge.fury.io/rb/veritrans)
[![Build Status](https://travis-ci.org/veritrans/veritrans-ruby.svg?branch=master)](https://travis-ci.org/veritrans/veritrans-ruby)

## How to use (Rails)

### Add gem veritrans to Gemfile

```ruby
gem 'veritrans'
```

    bundle install

### Generate veritrans.yml

    rails g veritrans:install

### Create simple payment form (optional)

    rails g veritrans:payment_form

### Edit api keys in config/veritrans.yml

```yml
# config/veritrans.yml
development:
  client_key: # your api client key
  server_key: # your api client key
```

## STEP 1: Process credit cards


#### VT-Web

*If you want to use VT-Web, add `payment_type: "VTWEB"`*

```ruby
@result = Veritrans.charge(
  payment_type: "VTWEB",
  transaction_details: {
    order_id: "my-unique-order-id",
    gross_amount: 100_000
  }
)

redirect_to @result.redirect_url
```

#### VT-Direct

It's little more complicated, because credit_card is sensitive data,
you need put credit card number in our safe storage first using `veritrans.js` library, then send received token to with other payment details.

We don't want you to send credit card number to your server, especially for websites not using https.

File: "app/views/shared/_veritrans_include.erb"

```html
<script src="//api.sandbox.veritrans.co.id/v2/assets/veritrans.js"></script>

<script type="text/javascript">
  Veritrans.url = "<%= Veritrans.config.api_host %>/v2/token";
  Veritrans.client_key = "<%= Veritrans.config.client_key %>";
</script>
```

Payment form: (same as if you use `rails g veritrans:payment_form`)

```erb
<%= form_tag "/charge_vtdirect", id: "card_form" do %>
  <%= hidden_field_tag :token_id, nil, id: "card_token" %>
  <%= hidden_field_tag :gross_amount, 30000 %>
  <p>
    <%= label_tag "card_number", "Card number" %>
    <%= text_field_tag :card_number, "4811 1111 1111 1114", name: nil, style: "width: 150px" %>
  </p>
  <p>
    <%= label_tag "card_cvc", "Security Code" %>
    <%= text_field_tag :card_cvc, "123", name: nil, style: "width: 30px", placeholder: "cvc" %>
  </p>
  <p>
    <%= label_tag "card_exp", "Expiration date" %>
    <%= text_field_tag :card_exp, "12 / 16", name: nil, placeholder: "MM / YY" %>
  </p>
  <%= submit_tag "Make payment", id: "submit_btn" %>
<% end %>
<iframe id="3d-secure-iframe" style="display: none; width: 500px; height: 600px"></iframe>
```

For sinatra:

```html
<form action="/charge_vtdirect" method="post" id="card_form">
  <input type="hidden" name="token_id" id="card_token">
  <input type="hidden" id="gross_amount" value="30000">
  <p>
    <label for="card_number">Card number</label>
    <input type="text" id="card_number" style="width: 150px" value="4811 1111 1111 1114">
  </p>
  <p>
    <label for="card_cvc">Security Code</label>
    <input type="text" id="card_cvc" style="width: 30px" placeholder="cvc" value="123">
  </p>
  <p>
    <label for="card_exp">Expiration date</label>
    <input type="text" id="card_exp" placeholder="MM / YY" value="12 / 16">
  </p>
  <p>
    <label for="card_secure">3D-secure</label>
    <input id="card_secure" name="card_secure" type="checkbox" value="1" />
  </p>
  <input id="submit_btn" type="submit">
</form>
<iframe id="3d-secure-iframe" style="display: none; width: 500px; height: 600px"></iframe>
```

Sending "get-token" request:

```js
$(document).ready(function () {
  // function to prepare our credit card data before send
  function createTokenData() {
    return {
      card_number: $('#card_number').val(),
      card_cvv: $('#card_cvc').val(),
      card_exp_month: $('#card_exp').val().match(/(\d+) \//)[1],
      card_exp_year: '20' + $('#card_exp').val().match(/\/ (\d+)/)[1],
      gross_amount: $('#gross_amount').val(),
      secure: $('#card_secure')[0].checked
    };
  }
  // Add custom event for form submition
  $('#card_form').on('submit', function (event) {
    var form = this;
    event.preventDefault();

    Veritrans.token(createTokenData, function (data) {
      console.log('Token data:', data);
      // when you making 3D-secure transaction,
      // this callback function will be called again after user confirm 3d-secure
      // but you can also redirect on server side
      if (data.redirect_url) {
        // if we get url then it's 3d-secure transaction
        // so we need to open that page
        $('#3d-secure-iframe').attr('src', data.redirect_url).show();
      // if no redirect_url and we have token_id then just make charge request
      } else if (data.token_id) {
        $('#card_token').val(data.token_id);
        form.submit();
      // if no redirect_url and no token_id, then it should be error
      } else {
        alert(data.validation_messages ? data.validation_messages.join("\n") : data.status_message);
      }
    });
  });
});
```

On a server side:

```ruby
@result = Veritrans.charge(
  payment_type: "credit_card",
  credit_card: { token_id: params[:token_id] },
  transaction_details: {
    order_id: @payment.order_id,
    gross_amount: @payment.amount
  }
)
if @result.success?
  puts "Success"
end
```

## STEP 2: Process not credit cards

We provide many payment channels to receive money, but API is almost same.

For VT-Web in only one request, and payment page will have all available payment options.

For VT-Direct you have to specify payment method (token required only for credit card transactions).

```ruby
@result = Veritrans.charge(
  payment_type: "bank_transfer",
  bank_transfer: { bank: 'permata' },
  transaction_details: {
    order_id: @payment.order_id,
    gross_amount: @payment.amount
  }
)
puts "Please send money to account no. #{@result.permata_va_number} in bank Permata"
```

See [our documentation](http://docs.veritrans.co.id/sandbox/charge.html) for other available options.


## STEP 3: Receive notification callback

For every transaction success and failed we will send you HTTP POST notification (aka webhook)

First you should set callback url in our dashboard https://my.sandbox.veritrans.co.id/settings/vtweb_configuration

For testing in development phase please read our [Testing webhooks tutorial](https://github.com/veritrans/veritrans-ruby/blob/new_api/testing_webhooks.md) and [command line tool](#command-line-tool)


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
    Payment.find_by(order_id: payment.order_id).mark_paid!(payment.masked_card)
  end

  events.subscribe('payment.failed', 'payment.challenge') do |payment|
    Payment.find_by(order_id: payment.order_id) ...
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

#### Command line tool

**Installation**

    $ gem install veritrans

**Usage**

Testing http notification:

    $ veritrans testhook http://localhost:3000/vt_events
    $ veritrans testhook -o my-order-1 -c ~/path/to/veritrans.yml http://localhost:3000/vt_events



#### Get help

* [Veritrans gem reference](https://github.com/veritrans/veritrans-ruby/blob/master/api_reference.md)
* [Veritrans login](https://my.veritrans.co.id/login)
* [Veritrans registration](https://my.veritrans.co.id/register)
* [Veritrans documentation](http://docs.veritrans.co.id)
* Technical support [support@veritrans.co.id](mailto:support@veritrans.co.id)
