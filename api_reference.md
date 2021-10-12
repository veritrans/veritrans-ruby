# API Reference

This is only partial reference of the APIs that are implemented in this Ruby Gem. For more details refer to [documentation](https://api-docs.midtrans.com/)


<table>
  <thead>
    <tr>
      <th>Method</th>
      <th>Descripion</th>
      <th>Http Method</th>
      <th>URL</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <td><a href="#charge">Midtrans.charge(data)</a></td>
      <td>Charge Transaction (Core API)</td>
      <td>POST</td>
      <td>api.midtrans.com/v2/charge</td>
    </tr>
    <tr>
      <td><a href="#token">Midtrans.create_card_token(data)</a></td>
      <td>Get Token for Card</td>
      <td>GET</td>
      <td>api.midtrans.com/v2/token</td>
    </tr>
    <tr>
      <td><a href="#status">Midtrans.status(id)</a></td>
      <td>Get Last Status</td>
      <td>GET</td>
      <td>api.midtrans.com/v2/{id}/status</td>
    </tr>
    <tr>
      <td><a href="#cancel">Midtrans.cancel(id)</a></td>
      <td>Cancel Transaction</td>
      <td>POST</td>
      <td>api.midtrans.com/v2/{id}/cancel</td>
    </tr>
    <tr>
      <td><a href="#approve">Midtrans.approve(id)</a></td>
      <td>Approve Challenge Transaction</td>
      <td>POST</td>
      <td>api.midtrans.com/v2/{id}/approve</td>
    </tr>
    <tr>
      <td><a href="#refund">Midtrans.refund(id)</a></td>
      <td>Refund Successful Transaction</td>
      <td>POST</td>
      <td>api.midtrans.com/v2/{id}/refund</td>
    </tr>
    <tr>
      <td><a href="#capture">Midtrans.capture(id)</a></td>
      <td>Capture Authorise Transaction</td>
      <td>POST</td>
      <td>api.midtrans.com/v2/{id}/capture</td>
    </tr>
    <tr>
      <td><a href="#expire">Midtrans.expire(id)</a></td>
      <td>Expire Pending Transaction</td>
      <td>POST</td>
      <td>api.midtrans.com/v2/{id}/expire</td>
    </tr>
    <tr>
      <td><a href="#deny">Midtrans.deny(id)</a></td>
      <td>Deny Challenged Transaction</td>
      <td>POST</td>
      <td>api.midtrans.com/v2/{id}/deny</td>
    </tr>
        <tr>
      <td><a href="#snap">Midtrans.create_snap_token(data)</a></td>
      <td>Charge Transaction (SNAP)</td>
      <td>POST</td>
      <td>app.midtrans.com/snap/v1/transactions</td>
    </tr>
    <tr>
      <td><a href="#link">Midtrans.link_payment_account(data)</a></td>
      <td>Link the customer's payment provider account to be used for payments using specific payment channel.</td>
      <td>POST</td>
      <td>api.midtrans.com/v2/pay/account</td>
    </tr>
        <tr>
      <td><a href="#get_payment_account">Midtrans.get_payment_account(id)</a></td>
      <td>Get account to use for specific payment channel.</td>
      <td>GET</td>
      <td>api.midtrans.com/v2/pay/account/{account_id}</td>
    </tr>
    <tr>
      <td><a href="#unlink_payment_account">Midtrans.unlink_payment_account(id)</a></td>
      <td>Unlink the linked customer account.</td>
      <td>POST</td>
      <td>api.midtrans.com/v2/pay/account/{account_id}/unbind</td>
    </tr>
      <tr>
      <td><a href="#create_subscription">Midtrans.create_subscription(data)</a></td>
      <td>Create a subscription transaction</td>
      <td>POST</td>
      <td>api.midtrans.com/v1/subscriptions</td>
    </tr>
      <tr>
      <td><a href="#get_subscription">Midtrans.get_subscription(id)</a></td>
      <td>Retrieve the subscription details of a customer</td>
      <td>GET</td>
      <td>api.midtrans.com/v1/subscriptions/{subscription_id}</td>
    </tr>
      <tr>
      <td><a href="#disable_subscription">Midtrans.disable_subscription(id)</a></td>
      <td>Disable a customer's subscription account</td>
      <td>POST</td>
      <td>api.midtrans.com/v1/subscriptions/{subscription_id}/disable</td>
    </tr>
      <tr>
      <td><a href="#enable_subscription">Midtrans.enable_subscription(id)</a></td>
      <td>Enable a customer's subscription account</td>
      <td>POST</td>
      <td>api.midtrans.com/v1/subscriptions/{subscription_id}/enable</td>
    </tr>
    <tr>
      <td><a href="#update_subscription">Midtrans.update_subscription(data)</a></td>
      <td>Update the details of a customer's existing subscription account</td>
      <td>PATCH</td>
      <td>api.midtrans.com/v1/subscriptions/{subscription_id}</td>
    </tr>
  </tbody>
</table>


## Usage Example

### Create Transaction

<a name="charge"></a>
#### Core API

Perform a transaction with various available payment methods and features. Example below: credit card charge.
```ruby
response = Midtrans.charge({
                       # *required
                       payment_type: "credit_card",
                       # *required
                       transaction_details: {
                         order_id: "order-2",
                         gross_amount: 100_000
                       },
                       # *required (but different for different payment type)
                       credit_card: {
                         token_id: "dcd6cd71-bc4c-4f4b-8752-49cb0a3f204c",
                         bank: "cimb"
                       },
                       # optional
                       item_details: [
                         {
                           id: "ITEM1",
                           price: 100_000,
                           quantity: 1,
                           name: "T-Short Infinity"
                         }
                       ],
                       # optional
                       customer_details: {
                         first_name: "Nadia",
                         last_name: "Modjo",
                         email: "noreply@midtrans.com",
                         phone: "+6281 123 12345",
                         billing_address: {
                           address: "Jalan Raya Kalijati",
                           city: "Subang",
                           postal_code: "41271",
                         },
                       },
                       # optional
                       custom_field1: "age: 25",
                       custom_field2: "new_year_promo",
                       custom_field3: "submerchant_id: 23"
                     });
# this will be Hash representation of the API JSON response:
puts response.data == {
  status_code: "200",
  status_message: "Success, Credit Card transaction is successful",
  transaction_id: "20bcc3dd-6fa5-4a9a-a9ad-615af992aa3d",
  masked_card: "481111-1114",
  order_id: "order-2",
  payment_type: "credit_card",
  transaction_time: "2014-11-03 16:22:52",
  transaction_status: "capture",
  fraud_status: "accept",
  approval_code: "1415006572598",
  gross_amount: "100000.00"
}
```

<a name="snap"></a>
#### Snap
Snap allows you (as a merchant) to easily integrate with Midtrans payment system to start accepting payments. Snap payment page can be displayed as a seamless pop-up within your web/app during checkout, or as a (Midtrans hosted) web page url redirect.
Example below: create Snap transaction.
```ruby
response = Midtrans.create_snap_token(
        transaction_details: {
                order_id: generate_order_id,
                gross_amount: 100000
        })
# this will be Hash representation of the API JSON response:
puts response.data == {
  status_code: "201",
  "token": "2b3ccb6c-d0fb-499a-9d46-ef53ad51fe62",
  "redirect_url": "https://app.sandbox.midtrans.com/snap/v2/vtweb/2b3ccb6c-d0fb-499a-9d46-ef53ad51fe62"
}
```

<a name="token"></a>

### Create card token

Creating card token, in production create token should be handled on Frontend please refer to [API docs](https://docs.midtrans.com/en/core-api/credit-card).

```ruby
card =
  {
    card_number: 4_811_111_111_111_114,
    card_cvv: 123,
    card_exp_month: 12,
    card_exp_year: 2025
  }

result = Midtrans.create_card_token(card)

result.token_id == "481111-1114-a901971f-2f1b-4781-802a-df326fbf0e9c"
```

<a name="status"></a>

### Status

Get Transaction Status is triggered to obtain the transaction_status and other details of a specific transaction.
```ruby
response = Midtrans.status("ruby-lib-test-1633926689")

# this will be Hash representation of the API JSON response:
puts response.data == {
  transaction_time: "2021-10-11 11:31:29",
  gross_amount: "10000.00",
  currency: "IDR",
  order_id: "ruby-lib-test-1633926689",
  payment_type: "bank_transfer",
  signature_key: "412c0a69df9c74d05666ffb079d09b404e3d596b927dbb027bd470d072401a767b0f9ad4659248118979ce274e5bcec3dd683abf9e279ce001eab67f49de5866",
  status_code: "201",
  transaction_id: "569a305d-9fec-4fa1-a707-294ee97f7b2a",
  transaction_status: "pending",
  fraud_status: "accept",
  status_message: "Success, transaction is found",
  merchant_id: "G686051436",
  permata_va_number: "514003740741123"
}
```

<a name="cancel"></a>

### Cancel

Cancel a transaction with a specific order_id. Cancelation can only be done before settlement process.

```ruby
response = Midtrans.cancel("ruby-lib-test-1633926562")

# this will be Hash representation of the API JSON response:
puts response.data == {
  status_code: "200",
  status_message: "Success, transaction is canceled",
  transaction_id: "7e75d03e-54a4-44c6-a385-6bbdd28d85c3",
  order_id: "ruby-lib-test-1633926562",
  gross_amount: "10000.00",
  currency: "IDR",
  payment_type: "bank_transfer",
  transaction_time: "2021-10-11 11:29:23",
  transaction_status: "cancel",
  fraud_status: "accept",
  merchant_id: "G686051436"
}
```

<a name="approve"></a>

### Approve

Approve transaction is triggered to accept the card payment transaction with `fraud_status:challenge`

```ruby
response = Midtrans.approve("ruby-lib-test-1633926990")

# this will be Hash representation of the API JSON response:
puts response.data == {
  status_code: "200",
  status_message: "Success, transaction is approved",
  bank: "bni",
  transaction_id: "23e5ad9a-c28c-466c-8894-cbbc5445eb97",
  masked_card: "551011-1115",
  order_id: "ruby-lib-test-1633926990",
  merchant_id: "G686051436",
  payment_type: "credit_card",
  transaction_time: "2021-10-11 11:36:33",
  transaction_status: "capture",
  fraud_status: "accept",
  gross_amount: "10000.00",
  currency: "IDR",
  approval_code: "1633926993796"
}
```

<a name="refund"></a>

### Refund

Refund transaction is triggered to update the transaction status to refund, when the customer decides to cancel a completed transaction or a payment that is settled.

```ruby
response = Midtrans.refund("ruby-example-coreapi-creditcard-1633678954")

# this will be Hash representation of the API JSON response:
puts response.data == {
  status_code: "200",
  status_message: "Success, refund offline request is approved",
  bank: "bni",
  transaction_id: "b2a62a3d-03e1-4232-b6b4-5832d5aa7eeb",
  order_id: "ruby-example-coreapi-creditcard-1633678954",
  merchant_id: "G686051436",
  gross_amount: "10000.00",
  currency: "IDR",
  payment_type: "credit_card",
  transaction_time: "2021-10-08 14:42:34",
  transaction_status: "partial_refund",
  fraud_status: "accept",
  approval_code: "1633678955297",
  masked_card: "521111-1117",
  refund_chargeback_id: 101293,
  refund_chargeback_uuid: "c720cb44-272d-4b64-b97d-47d89e86da02",
  refund_amount: "2000.00",
  settlement_time: "2021-10-09 16:35:04",
  refund_key: "reference1"
}
```

<a name="capture"></a>

### Capture

This API method is only for merchants who have pre-authorise feature (can be requested) and have pre-authorise payments.

```ruby
response = Midtrans.capture("testing-0.2072-1415086078", 101_000)
response.success? # => true
```

<a name="expire"></a>

### Expire

To expire pending transactions. For example if a merchant chooses to pay via ATM and then the user changes their mind
and now wants to pay with credit card. In this situation the previous transaction should be expired. The same order_id
can be used again.

```ruby
response = Midtrans.expire("ruby-lib-test-1633927809")
# this will be Hash representation of the API JSON response:
puts response.data == {
  status_code: "407",
  status_message: "Success, transaction has expired",
  transaction_id: "6ff22198-875e-4a6d-a15d-e23ab3345a4d",
  order_id: "ruby-lib-test-1633927809",
  gross_amount: "10000.00",
  currency: "IDR",
  payment_type: "bank_transfer",
  transaction_time: "2021-10-11 11:50:09",
  transaction_status: "expire",
  fraud_status: "accept",
  merchant_id: "G686051436"  
}
```

<a name="deny"></a>

### Deny

Deny transaction is triggered to immediately deny the card payment transaction with `fraud_status:challenge`
```ruby
response = Midtrans.deny("ruby-lib-test-1633927987")

# this will be Hash representation of the API JSON response:
puts response.data == {
  status_code: "200",
  status_message: "Success, transaction is denied",
  bank: "bni",
  transaction_id: "91cf84b9-1523-45b4-adf7-cd76751f71c6",
  masked_card: "551011-1115",
  order_id: "ruby-lib-test-1633927987",
  merchant_id: "G686051436",
  payment_type: "credit_card",
  transaction_time: "2021-10-11 11:53:07",
  transaction_status: "cancel",
  fraud_status: "deny",
  gross_amount: "10000.00",
  currency: "IDR",
  approval_code: "1633927988537"
}
```

<a name="link"></a>
### Link payment account
Link the customer account to be used for specific payment channels.

```ruby
param = {
  "payment_type": "gopay",
  "gopay_partner": {
    "phone_number": "81987654321",
    "country_code": "62",
    "redirect_url": "https://www.gojek.com"
  }
}

response = Midtrans.link_payment_account(param)

# this will be Hash representation of the API JSON response:
puts response.data == {
        "status_code": "201",
        "payment_type": "gopay",
        "account_id": "f2b21e66-c72d-4fc2-9296-7b2682c82a96",
        "account_status": "PENDING",
        "actions": [
                {
                        "name": "activation-deeplink",
                        "method": "GET",
                        "url": "https://api.sandbox.midtrans.com/v2/pay/account/gpar_8a719131-cd69-44ca-bd12-5c134f925f06/link"
                },
                {
                        "name": "activation-link-url",
                        "method": "GET",
                        "url": "https://api.sandbox.midtrans.com/v2/pay/account/gpar_8a719131-cd69-44ca-bd12-5c134f925f06/link"
                },
                {
                        "name": "activation-link-app",
                        "method": "GET",
                        "url": "https://simulator.sandbox.midtrans.com/gopay/partner/web/otp?id=18060c31-2542-43be-a1b5-bd5c0cdd1f8d"
                }
        ],
        "metadata": {
                "reference_id": "ec20c478-f81a-4f60-91a8-725cf0c1fd94"
        }
}
```

<a name="get_payment_account"></a>
### Get payment account
Get Pay Account is triggered to get a customer account to use for specific payment channel.
```ruby
response = Midtrans.get_payment_account("f2b21e66-c72d-4fc2-9296-7b2682c82a96")

# this will be Hash representation of the API JSON response:
puts response.data == {
        "status_code": "201",
        "payment_type": "gopay",
        "account_id": "f2b21e66-c72d-4fc2-9296-7b2682c82a96",
        "account_status": "PENDING"
}
```

<a name="unlink_payment_account"></a>
### Unlink payment account
Unbind Pay Account is triggered to remove the linked customer account.
```ruby
response = Midtrans.unlink_payment_account("f2b21e66-c72d-4fc2-9296-7b2682c82a96")

# this will be Hash representation of the API JSON response:
puts response.data == {
        "status_code": "204",
        "payment_type": "gopay",
        "account_id": "f2b21e66-c72d-4fc2-9296-7b2682c82a96",
        "account_status": "DISABLED",
        "channel_response_code": "0",
        "channel_response_message": "Process service request successfully."
}
```

<a name="create_subscription"></a>
### Create subscription
Create a subscription transaction by sending all the details required to create a transaction. The details such as name, amount, currency, payment_type, token, and schedule are sent in the request. Successful request returns id status:active, and other subscription details.

```ruby
param = {
        "name": "MONTHLY_2021",
        "amount": "17000",
        "currency": "IDR",
        "payment_type": "credit_card",
        "token": "dummy",
        "schedule": {
                "interval": 1,
                "interval_unit": "month",
                "max_interval": 12,
                "start_time": "2021-10-10 07:25:01 +0700"
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

response = Midtrans.create_subscription(param)

# this will be Hash representation of the API JSON response:
puts response.data == {
        "id": "d137e7f4-9474-4fc2-9847-672e09cb16f6",
        "name": "MONTHLY_2021",
        "amount": "17000",
        "currency": "IDR",
        "created_at": "2021-09-28 10:40:29",
        "schedule": {
                "interval": 1,
                "current_interval": 0,
                "max_interval": 12,
                "interval_unit": "month",
                "start_time": "2021-10-10 07:25:01",
                "next_execution_at": "2021-10-10 07:25:01"
        },
        "status": "active",
        "token": "dummy",
        "payment_type": "credit_card",
        "transaction_ids": [

        ],
        "metadata": {
                "description": "Recurring payment for A"
        },
        "customer_details": {
                "email": "johndoe@email.com",
                "first_name": "John",
                "last_name": "Doe",
                "phone": "+62812345678"
        }
}
```

<a name="get_subscription"></a>
### Get subscription
Retrieve the subscription details of a customer using the subscription_id. Successful request returns subscription object and status:active.
```ruby
response = Midtrans.get_subscription("d137e7f4-9474-4fc2-9847-672e09cb16f6")

# this will be Hash representation of the API JSON response:
puts response.data == {
        "id": "d137e7f4-9474-4fc2-9847-672e09cb16f6",
        "name": "MONTHLY_2021",
        "amount": "17000",
        "currency": "IDR",
        "created_at": "2021-09-28 10:40:30",
        "schedule": {
                "interval": 1,
                "current_interval": 0,
                "max_interval": 12,
                "interval_unit": "month",
                "start_time": "2021-10-10 07:25:01",
                "next_execution_at": "2021-10-10 07:25:01"
        },
        "status": "active",
        "token": "dummy",
        "payment_type": "credit_card",
        "transaction_ids": [

        ],
        "metadata": {
                "description": "Recurring payment for A"
        },
        "customer_details": {
                "email": "johndoe@email.com",
                "first_name": "John",
                "last_name": "Doe",
                "phone": "+62812345678"
        }
}
```

<a name="disable_subscription"></a>
### Disable subscription
Disable a customer's subscription account with a specific subscription_id so that the customer is not charged for the subscription in the future. Successful request returns status_message indicating that the subscription details are updated.

```ruby
response = Midtrans.disable_subscription("d137e7f4-9474-4fc2-9847-672e09cb16f6")

# this will be Hash representation of the API JSON response:
puts response.data == {
        "status_message": "Subscription is updated."
}
```

<a name="enable_subscription"></a>
### Enable subscription
Activate a customer's subscription account with a specific subscription_id, so that the customer can start paying for the subscription immediately. Successful request returns status_message indicating that the subscription details are updated.
```ruby
response = Midtrans.enable_subscription("d137e7f4-9474-4fc2-9847-672e09cb16f6")

# this will be Hash representation of the API JSON response:
puts response.data == {
        "status_message": "Subscription is updated."
}
```

<a name="update_subscription"></a>
### Update subscription
Update the details of a customer's existing subscription account with the specific subscription_id. Successful request returns status_message indicating that the subscription details are updated.
```ruby
param = {
  "name": "MONTHLY_2021",
  "amount": "21000",
  "currency": "IDR",
  "token": "dummy",
  "schedule": {
    "interval": 1
  }
}

response = Midtrans.update_subscription("d137e7f4-9474-4fc2-9847-672e09cb16f6", param)

# this will be Hash representation of the API JSON response:
puts response.data == {
        "status_message": "Subscription is updated."
}
```

## Get json field value from Midtrans API result
```ruby
result = Midtrans.charge(...)

# If in the future there is a new attribute in the Midtrans Result.
# Recommended retrieve like example below.
# :new_attribute is the new field name in API response JSON
result.data[:new_attribute]

# Alternatively you can also access like below.
# But make sure the new field name already show in API response JSON, if not will trigger error.
result.new_attribute
```

* `Midtrans::Result#success?` - `boolean`, Based on `status_code` field in API response JSON
* `Midtrans::Result#status_code` - `integer`, e.g. 200, 402. Documentation https://api-docs.midtrans.com/#status-code
* `Midtrans::Result#status_message` - `string`, e.g."Success, Credit Card transaction is successful"
* `Midtrans::Result#redirect_url` - `string`, For Snap payment page, where customer can be redirected to complete the payment
* `Midtrans::Result#body` - `string`, Raw HTTP response body
* `Midtrans::Result#data` - `hash`, Parsed API response JSON body as hash
* `Midtrans::Result#response` - Raw `Excon::Response` instance