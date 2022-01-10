# Midtrans Ruby library

Midtrans ❤️ Ruby!

This is the Official Ruby API client/library for Midtrans Payment API. Visit [https://midtrans.com](https://midtrans.com). More information about the product and see documentation at [http://docs.midtrans.com](https://docs.midtrans.com) for more technical details.

[![Gem Version](https://badge.fury.io/rb/veritrans.svg)](http://badge.fury.io/rb/veritrans)
[![Build Status](https://travis-ci.org/veritrans/veritrans-ruby.svg?branch=master)](https://travis-ci.org/veritrans/veritrans-ruby)

## 1. Installation

### Using Gemfile
Add gem veritrans to Gemfile
```ruby
gem 'veritrans'
```
Run this command in your terminal
```ruby
gem install veritrans
```
```ruby
bundle install
```

## 2. Usage
### 2.1 Choose Product/Method

We have [3 different products](https://docs.midtrans.com/en/welcome/index.html) of payment that you can use:
- [Snap](#22A-snap) - Customizable payment popup will appear on **your web/app** (no redirection). [doc ref](https://snap-docs.midtrans.com/)
- [Snap Redirect](#22B-snap-redirect) - Customer need to be redirected to payment url **hosted by midtrans**. [doc ref](https://snap-docs.midtrans.com/)
- [Core API (VT-Direct)](#22C-core-api-vt-direct) - Basic backend implementation, you can customize the frontend embedded on **your web/app** as you like (no redirection). [doc ref](https://api-docs.midtrans.com/)

Choose one that you think best for your unique needs.

### 2.2 Client Initialization and Configuration

Get your client key and server key from [Midtrans Dashboard](https://dashboard.midtrans.com)

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

Alternatively, you can also set config by declaring each one like below:

```ruby
Midtrans.config.server_key = "your server key"
Midtrans.config.client_key = "your client key"
Midtrans.config.api_host = "https://api.sandbox.midtrans.com"
```
Follow the steps given below to switch to Midtrans Production environment and to accept real payments from real customers.
1. Change api_host URL from `https://api.sandbox.midtrans.com` to `https://api.midtrans.com`.
2. Use Client Key and Server Key for Production environment. For more details, refer to [Retrieving API Access Keys](https://docs.midtrans.com/en/midtrans-account/overview?id=retrieving-api-access-keys).

### 2.2.A Snap
You can see Snap example [with Sinatra](example/sinatra) and [without framework](example/snap).

```ruby
# Create Snap payment page, with this version returning full API response
create_snap_token(parameter)

# Create Snap payment page, with this version returning token
create_snap_token_string(parameter)

# Create Snap payment page, with this version returning redirect url
create_snap_redirect_url_str(parameter)
```
`parameter` is Object or String of JSON of [SNAP Parameter](https://snap-docs.midtrans.com/#json-objects)

#### Get Snap Token

```ruby
result = Midtrans.create_snap_token(
  transaction_details: {
    order_id: "test-transaction-order-123",
    gross_amount: 100000,
    secure: true
  }
)
@token = result.token
```

#### Initialize Snap JS when customer click pay button

On frontend / html:
Replace `PUT_TRANSACTION_TOKEN_HERE` with `transactionToken` acquired above
```html
<html>
  <body>
    <button id="pay-button">Pay!</button>
    <pre><div id="result-json">JSON result will appear here after payment:<br></div></pre> 

<!-- TODO: Remove ".sandbox" from script src URL for production environment. Also input your client key in "data-client-key" -->
    <script src="https://app.sandbox.midtrans.com/snap/snap.js" data-client-key="<Set your ClientKey here>"></script>
    <script type="text/javascript">
      document.getElementById('pay-button').onclick = function(){
        // SnapToken acquired from previous step
        snap.pay('PUT_TRANSACTION_TOKEN_HERE', {
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
</html>
```

### 2.2.B Snap Redirect
You can see Snap example [with Sinatra](example/sinatra) and [without framework](example/snap).

#### Get Redirection URL of a Payment Page

```ruby
result = Midtrans.create_snap_redirect_url(
  transaction_details: {
    order_id: "test-transaction-order-123",
    gross_amount: 100000,
    secure: true
  }
)
@redirecturl = result.redirect_url
```

### 2.2.C Core API (VT-Direct)
You can see some Core API examples [with Sinatra](example/sinatra) and [without framework](example/coreapi).

Available methods for `CoreApi` class

```ruby
# charge : Do `/charge` API request to Midtrans Core API
def charge(payment_type, data = nil)

# test_token : Do `/token` API request to Midtrans Core API
def test_token(options = {})
  
# point_inquiry : Do `/point_inquiry/{tokenId}` API request to Midtrans Core API 
def point_inquiry(token_id)

# status : Do `/{orderId}/status` API request to Midtrans Core API
def status(payment_id)

# approve : Do `/{orderId}/approve` API request to Midtrans Core API
def approve(payment_id, options = {})

# deny : Do `/{orderId}/deny` API request to Midtrans Core API
def deny(payment_id, options = {})

# cancel : Do `/{orderId}/cancel` API request to Midtrans Core API
def cancel(payment_id, options = {})

# expire : Do `/{orderId}/expire` API request to Midtrans Core API
def expire(payment_id)
 
# refund : Do `/{orderId}/refund` API request to Midtrans Core API
def refund(payment_id, options = {})

# capture : Do `/{orderId}/capture` API request to Midtrans Core API
def capture(payment_id, gross_amount, options = {})

# link_payment_account : Do `/pay/account` API request to Midtrans Core API
def link_payment_account(param)

# get_payment_account : Do `/pay/account/{account_id}` API request to Midtrans Core API
def get_payment_account(account_id)

# unlink_payment_account : Do `/pay/account/{account_id}/unbind` API request to Midtrans Core API
def unlink_payment_account(account_id)

# create_subscription : Do `/subscription` API request to Midtrans Core API
def create_subscription(param)

# get_subscription : Do `/subscription/{subscription_id}` API request to Midtrans Core API
def get_subscription(subscription_id)

# disable_subscription : Do `/subscription/{subscription_id}/disable` API request to Midtrans Core API
def disable_subscription(subscription_id)

# enable_subscription : Do `/subscription/{subscription_id}/enable` API request to Midtrans Core API
def enable_subscription(subscription_id)

# update_subscription : Do `/subscription/{subscription_id}` API request to Midtrans Core API
def update_subscription(subscription_id, param)
```

#### Credit Card Get Token

Get token should be handled on Frontend please refer to [API docs](https://docs.midtrans.com/en/core-api/credit-card).
Further example to demonstrate Core API card integration (including get card token on frontend), available on [Sinatra example](/example/sinatra)

#### Credit Card Charge

```ruby
result = Midtrans.charge(
  payment_type: "credit_card",
  credit_card: {
    token_id: "CREDIT_CARD_TOKEN", # change with your card token,
    authentication: true
  },
  transaction_details: {
    order_id: "test-transaction-12345",
    gross_amount: 20000
  })
# result.data this will be Hash representation of the API JSON response:
puts result.data
```

#### Credit Card 3DS Authentication

The credit card charge result may contains `redirect_url` for 3DS authentication. 3DS Authentication should be handled on Frontend please refer to [API docs](https://api-docs.midtrans.com/#card-features-3d-secure)

For full example on Credit Card 3DS transaction refer to:
- [Sinatra example](/example/sinatra) that implement Snap & Core Api

### 2.2.D Subscription API

You can see some Subscription API examples [here](example/subscription), [Subscription API Docs](https://api-docs.midtrans.com/#subscription-api).

#### Subscription API for Credit Card

To use subscription API for credit card, you should first obtain the 1-click saved token, [refer to this docs.](https://docs.midtrans.com/en/core-api/advanced-features?id=recurring-transaction-with-subscriptions-api)
You will receive `saved_token_id` as part of the response when the initial card payment is accepted (will also available in the HTTP notification's JSON), [refer to this docs.](https://docs.midtrans.com/en/core-api/advanced-features?id=sample-3ds-authenticate-json-response-for-the-first-transaction)
```ruby
require 'veritrans'
# Set Midtrans config
Midtrans.config.server_key = "your server key"
Midtrans.config.client_key = "your client key"
Midtrans.config.api_host = "https://api.sandbox.midtrans.com"
# Prepare parameter
parameter = {
  "name": "monthly_subscription",
  "amount": "14000",
  "currency": "IDR",
  "payment_type": "credit_card",
  "token": saved_token_id,
  "schedule": {
    "interval": 1,
    "interval_unit": "month",
    "max_interval": 12,
    #start_time value is just a sample time & should be replaced with a valid future time.
    "start_time": "2022-12-20 07:00:00 +0700"
  },
  "metadata": {
    "description": "Recurring payment for A"
  },
  "customer_details": {
    "first_name": "John",
    "last_name": "Doe",
    "email": "johndoe@email.com",
    "phone": "+62812345678"
  }
}

result = Midtrans.create_subscription(parameter)
puts "Create subscription response : #{result.data}"

result_get_subs = Midtrans.get_subscription(subscription_id)
puts "get subscription response : #{result_get_subs.data}"

result_enable_subs = Midtrans.enable_subscription(subscription_id)
puts "enable subscription response : #{result_enable_subs.data}"

# update subscription by subscription_id and update_subscription_param
result_update_subs = Midtrans.update_subscription(subscription_id, update_subscription_param)
puts "update subscription response : #{result_update_subs.data}"

# disable subscription by subscription_id
result_disable_subs = Midtrans.disable_subscription(subscription_id)
puts "disable subscription response : #{result_disable_subs.data}"
```

#### Subscription API for Gopay

To use subscription API for gopay, you should first link your customer gopay account with gopay tokenization API, [refer to this section.](#22e-tokenization-api) You will receive gopay payment token using `getPaymentAccount` API call. You can see some Subscription API examples [here](example/subscription)

### 2.2.E Tokenization API
You can see some Tokenization API examples [here](examples/tokenization), [Tokenization API Docs.](https://api-docs.midtrans.com/#gopay-tokenization)
```ruby
require 'veritrans'
# Set Midtrans config
Midtrans.config.server_key = "your server key"
Midtrans.config.client_key = "your client key"
Midtrans.config.api_host = "https://api.sandbox.midtrans.com"
# Prepare parameter
parameter = {
  "payment_type": "gopay",
  "gopay_partner": {
    "phone_number": "81987654321",
    "country_code": "62",
    "redirect_url": "https://www.gojek.com"
  }
}

result = Midtrans.link_payment_account(parameter)
puts "Create pay account response : #{result.data}"

result_get_account = Midtrans.get_payment_account(active_account_id)
puts "Get pay account response : #{result_get_account.data}"

result_unlink = Midtrans.unlink_payment_account(active_account_id)
puts "Unlink response : #{result_unlink.data}"
```

### 2.3 Handle HTTP Notification
> **IMPORTANT NOTE**: To update transaction status on your backend/database, **DO NOT** solely rely on frontend callbacks! For security reason to make sure the status is authentically coming from Midtrans, only update transaction status based on HTTP Notification or API Get Status.

Create separated web endpoint (notification url) to receive HTTP POST notification callback/webhook.
HTTP notification will be sent whenever transaction status is changed.
Example also available [here](example/sinatra)

```ruby
post_body = JSON.parse(request.body.read)
notification = Midtrans.status(post_body['transaction_id'])

order_id = notification.data[:order_id]
payment_type = notification.data[:payment_type]
transaction_status = notification.data[:transaction_status]
fraud_status = notification.data[:fraud_status]

puts "Transaction order_id: #{order_id}"
puts "Payment type:   #{payment_type}"
puts "Transaction status: #{transaction_status}"
puts "Fraud status:   #{fraud_status}"

return "Transaction notification received. Order ID: #{order_id}. Transaction status: #{transaction_status}. Fraud status: #{fraud_status}"

# Sample transactionStatus handling logic
if transaction_status == "capture" && fraud_status == "challange"
  # TODO set transaction status on your databaase to 'challenge'
elsif transaction_status == "capture" && fraud_status == "success"
  # TODO set transaction status on your databaase to 'success'
elsif transaction_status == "settlement"
  # TODO set transaction status on your databaase to 'success'
elsif transaction_status == "deny"
  # TODO you can ignore 'deny', because most of the time it allows payment retries
elsif transaction_status == "cancel" || transaction_status == "expire"
  # TODO set transaction status on your databaase to 'failure'
elsif transaction_status == "pending"
  # Todo set transaction status on your databaase to 'pending' / waiting payment
end
```

### 2.4 Transaction Action
For full example on transaction action refer to: [Api Reference](api_reference.md)

## 3. Handling Error / Exception
When using function that result in Midtrans API call e.g: `Midtrans.charge(...)` or `Midtrans.create_snap_token(...)`
there's a chance it may throw error (`MidtransError` object), the error object will contains below properties that can be used as information to your error handling logic:

```ruby
begin
  Midtrans.create_snap_token(parameter)
rescue MidtransError => e
  puts e.message # Basic error message string
  puts e.http_status_code # HTTP status code e.g: 400, 401, etc.
  puts e.api_response # API response body in String
  puts e.raw_http_client_data # Raw HTTP client response
end
```

## 4. Advanced Usage
### Override Notification URL

You can opt to change or add custom notification urls on every transaction. It can be achieved by adding additional HTTP headers into charge request.
```ruby
# Add new notification url(s) alongside the settings on Midtrans Dashboard Portal (MAP)
Midtrans.config.append_notif_url = "https://example.com/test1,https://example.com/test2"
# Use new notification url(s) disregarding the settings on Midtrans Dashboard Portal (MAP)
Midtrans.config.override_notif_url = "https://example.com/test1"
```

[More details](https://api-docs.midtrans.com/#override-notification-url)
> **Note:** When both `appendNotifUrl` and `overrideNotifUrl` are used together then only `overrideNotifUrl` will be used.

> Both header can only receive up to maximum of **3 urls**.

### Idempotency-Key
Is a unique value that is put on header on API request. Midtrans API accept Idempotency-Key on header to safely handle retry request
without performing the same operation twice. This is helpful for cases where merchant didn't receive the response because of network issue or other unexpected error.
You can opt to add idempotency key by adding additional HTTP headers into charge request.
```ruby
Midtrans.config.idempotency_key = "Unique-ID"
```
[More details](http://api-docs.midtrans.com/#idempotent-requests)

### Log Configuration
By default if you are using Rails, gem Veritrans will show information via Rails logger and in addition save important information to `RAILS_APP/log/Midtrans.log` <br>
You can configure it like example below:

```ruby
Midtrans.logger = Rails.logger
# To set custom logger
Midtrans.file_logger = Logger.new("./log/midtrans.log")
```

`Midtrans.file_logger` save information about:

* "charge", "cancel", "approve" api calls
* Validation errors for "charge", "cancel", "approve"
* Received http notifications
* Errors and exception while processing http notifications

----

### To see it in action, we have made example:

Sinatra, which demonstrate in as succint code as possible. Please [have a look here](https://github.com/veritrans/veritrans-ruby/tree/master/example/sinatra)


### Get help

* [Veritrans gem reference](https://github.com/veritrans/veritrans-ruby/blob/master/api_reference.md)
* [Midtrans login](https://account.midtrans.com/login)
* [Midtrans registration](https://account.midtrans.com/register)
* [Midtrans documentation](http://docs.midtrans.com)
* Technical support [support@midtrans.com](mailto:support@midtrans.com)

## Important Changes

### v2.4.0
- API client methods will now raise `MidtransError` when getting unexpected API response. You may need to update your error handling. [Handling Error / Exception](#3-Handling-Error--Exception)
- Removed features: CLI, TestingLib. Mainly removed due to no longer relevant/essential to this library's purpose.
