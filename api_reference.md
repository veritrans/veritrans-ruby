# API Reference

Here is only reference for API of this gem, to see complete information
please use our [documentation](http://docs.veritrans.co.id/sandbox/introduction.html)


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
      <td><a href="#charge">Veritrans.charge(data)</a></td>
      <td>Charge Transaction</td>
      <td>POST</td>
      <td>api.veritrans.co.id/v2/charge</td>
    </tr>
    <tr>
      <td><a href="#status">Veritrans.status(id)</a></td>
      <td>Get Last Status</td>
      <td>GET</td>
      <td>api.veritrans.co.id/v2/{id}/status</td>
    </tr>
    <tr>
      <td><a href="#cancel">Veritrans.cancel(id)</a></td>
      <td>Cancel Transaction</td>
      <td>POST</td>
      <td>api.veritrans.co.id/v2/{id}/cancel</td>
    </tr>
    <tr>
      <td><a href="#approve">Veritrans.approve(id)</a></td>
      <td>Approve Challenge Transaction</td>
      <td>POST</td>
      <td>api.veritrans.co.id/v2/{id}/approve</td>
    </tr>
    <tr>
      <td><a href="#capture">Veritrans.capture(id)</a></td>
      <td>Capture Authorise Transaction</td>
      <td>POST</td>
      <td>api.veritrans.co.id/v2/{id}/capture</td>
    </tr>
  </tbody>
</table>


<a name="charge"></a>

### Charge

Actually make transaction. But for vt-web create a redirect url, and for vt-link creates payment page

**For VT-Web:**

```ruby
q = Veritrans.charge({
  payment_type: "VTWEB",
  transaction_details: {
    order_id: "order-1",
    gross_amount: 100_000
  }
})

q.class # => Veritrans::Result
q.data == {
  status_code: "201",
  status_message: "OK, success do VTWeb transaction, please go to redirect_url",
  redirect_url: "https://vtweb.sandbox.veritrans.co.id/v2/vtweb/b27d421f-90ff-4427-83d2-fbe8acbbce89"
}
```

**For VT-Direct:**

```ruby
q = Veritrans.charge({
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
    email: "noreply@veritrans.co.id",
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

q.class # => Veritrans::Result
q.data == {
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

q.success? # => true
```


<a name="status"></a>
### Status

Return current status of transaction.

```ruby
q = Veritrans.status("order-2")

q.data == {
  status_code: "200",
  status_message: "Success, transaction found",
  transaction_id: "20bcc3dd-6fa5-4a9a-a9ad-615af992aa3d",
  masked_card: "481111-1114",
  order_id: "order-2",
  payment_type: "credit_card",
  transaction_time: "2014-11-03 16:22:52",
  transaction_status: "settlement",
  fraud_status: "accept",
  signature_key: "639af8e985f68526839e6ed04c1...",
  bank: "bni",
  gross_amount: "100000.00"
}
```


<a name="cancel"></a>
### Cancel

Cancel transaction, before it was settled. For credit card payments you can cancel it before we trigger settlement in bank.
Usually we do settlement next day after payment happen, about 4pm.

For internet banking, bank transfer, mobile payments, convenient store payments if user already made payment,
you can't cancel it as simple as credit card, but before user sent money you can cancel pending transactions.

```ruby
q = Veritrans.cancel("testing-0.2072-1415086078")

q.data == {
  status_code: "200",
  status_message: "Success, transaction is canceled",
  transaction_id: "b38f598a-59ab-4850-b311-2aa14c78bc45",
  masked_card: "481111-1114",
  order_id: "testing-0.2072-1415086078",
  payment_type: "credit_card",
  transaction_time: "2014-11-04 14:29:47",
  transaction_status: "cancel",
  fraud_status: "accept",
  bank: "bni",
  gross_amount: "100000.00"
}
```


<a name="approve"></a>
### Approve

Some transactions marked as challenge. If challenge you can approve it or cancel it. Usual way is to use our dashboard web interface,
but you also can do it programatically, via API

```ruby
q = Veritrans.cancel("testing-0.2072-1415086078")

q.data == {
  status_code: "200",
  status_message: "Success, transaction is approved",
  transaction_id: "8492c240-1600-465a-9bf1-808863410b0e",
  masked_card: "451111-1117",
  order_id: "testing-0.0501-1415086808",
  payment_type: "credit_card",
  transaction_time: "2014-11-04 14:41:58",
  transaction_status: "capture",
  fraud_status: "accept",
  bank: "bni",
  gross_amount: "100000.00"
}
```

<a name="capture"></a>
### Capture

This API method is only for merchants who have pre-authorise feature (can be requested) and have pre-authorise payments.

```ruby
q = Veritrans.capture("testing-0.2072-1415086078", 101_000)
q.success? # => true
```
