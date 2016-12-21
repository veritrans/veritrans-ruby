# Cable: Slack on Rails

1. To demonstrate Ruby language
2. To demonstrate the use of Midtrans library's SNAP in handling payment
3. To demonstrate ActionCable, ActiveRecords and Rails in general

Feel free to fork, copy, modify, etc.

## Setting up procedures

1. Install Ruby, Bundler, Ruby on Rails, Redis, and MySQL database.
2. Clone the repository
3. Run `bundle install` on the root folder of the cloned project
4. If your MySQL configuration is standard, you can directly run `rake db:create db:migrate`. Otherwise edit `config/database.yml` and then run the same command.
5. Run `rake db:seed` to initialise the database state with some data.
6. Run `rails s` to start the web server. By default the system is served at `http://localhost:3000` 
7. Run `bundle exec sidekiq` to run the sidekiq background job processor that process incoming chat message and properly broadcast them.

## How to make payment

Each payment link ("Beli") appear on a message that contains a pattern in the form of:

> (some text if any) jual (item name) (comma) (item price)

Example of texts that will create the "Beli" link:

1. Jual buku, 50.000
2. Nih gue jual stick PS, 50.000
3. Gue jual stick PS, 50.000; memory card, 200.000
