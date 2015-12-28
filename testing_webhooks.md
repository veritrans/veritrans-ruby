# Webhooks

For better security we recommend to use webhooks and check status of transaction via api.

Webhook is http post request that veritrans send to merchant's server when any transaction change status.
It can be success transaction, can be failed transaction, and when transaction settled.

Now you can set webhook url at https://my.sandbox.veritrans.co.id/settings/vtweb_configuration

## Veritrans command line tool

You can send testing request from command line:

```bash
gem install veritrans

# Send default data, payment which not exists
veritrans testhook http://localhost:3000/vt_events

# Get fetch real payment information and send
veritrans testhook -o my-order-1 -c ~/path/to/veritrans.yml http://localhost:3000/vt_events
```

## Test locally

Most of computers don't have public ip address, in that case you can't simply receive http requests on your computer.
If you're using wi-fi router you need to change router settings to make a route from router to your local computer.
To check if your ip is public, you can open http://www.whatismyip.com/, make some local http server and try to open it.
For example if your IP address is `117.102.113.10` and you started rails on port 3000, try to open http://117.102.113.10:3000 in your browser;
if you able to see your application, then your IP is public.

There are several tools to accept http requests if you can't do it directly.

* npm localtunnel
* https://ngrok.com/
* gem [ultrahook](http://www.ultrahook.com/)
* gem [forward](https://forwardhq.com/)

Or you can make ssh tunnel to your globally accessible server (if you have one)

    ssh -N -R 127.0.0.1:13000:localhost:3000 remoteuser@remote-host.com
    # 3000 - port on your local computer
    # 13000 - port witch will be accessible on remote computer
    # remoteuser@remote-host.com - your user and host

Also you can collect requests online for further inspection.

* http://requestb.in/
* http://httpi.pe/


## Trigger callback

To receive http notification from veritrans you can try to make transaction or use callback tester in merchant portal

https://my.sandbox.veritrans.co.id/settings/vtweb_configuration/test_callback


## Format

Veritrans will try to send message in JSON format:

```js
// Content-Type: application/json
{
  "status_code": "200",
  "status_message": "Veritrans payment notification",
  "transaction_id": "826acc53-14e0-4ae7-95e2-845bf0311579",
  "order_id": "2014040745",
  "payment_type": "credit_card",
  "transaction_time": "2014-04-07 16:22:36",
  "transaction_status": "capture",
  "fraud_status": "accept",
  "masked_card": "411111-1111",
  "gross_amount": "2700"
}

```