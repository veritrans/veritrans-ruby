> Warning: This note is for developer/maintainer of this package only

## Updating Package

- Make your changes
- Update `version` value on `version.rb` file
- To run all test `ruby -Itest all.rb`
- To run specific test `ruby snap_test.rb`
- If you are using Rubymine, you can right click folder test and choose `run all tests in test`

## Update Rubygems.org
- Run this command `gem build veritrans.gemspec`
- Run this command `gem push veritrans-2.4.0.gem`, after that you are required to enter email and password account in Rubygems.org
- You can get account Rubygems.org in `Account Access & Resources`
- If you are using Rubymine, you can use `Tools -> Gem -> Build Gem` and `Push Gem`