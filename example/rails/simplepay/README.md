# Simplepay

Example of checkout page using Midtrans Snap. A quick way to accept payment with
a beautiful user interface done for you.

This is a very simple, very minimalist example to demonstrate integrating
Midtrans Snap with Ruby on Rails. To start:

1. Install Ruby and Ruby on Rails
2. Clone the repository
3. `bundle install` on the directory
4. Run `rake db:drop db:create db:migrate`
5. Run `rails s`, and you are done. You can visit it at `http://127.0.0.1:3000`

The Midtrans configuration is located at `config/initializers/veritrans.rb`. 

## PaysController

PaysController handle the notification from Midtrans. As each payment is processed
asynchronously (you don't want your system to do nothing/wait when Midtrans system
is also channeling your charge request to the bank/payment providers), all merchant
need to implement the notification mechanism.

The notification mechanism on your part allow Midtrans to callback your system
and informing if the payment is really successful, or if the payment is rejected
due to some reasons. Therefore, payment notification is an integral part to
have a successful integration with Midtrans.

The notification infrastructure in the client's part is implemented on
`PaysController` which handle the callbacks from Midtrans (the `notify` action).
