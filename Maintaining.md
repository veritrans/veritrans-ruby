> Warning: This note is for developer/maintainer of this package only

## Updating Package

- Make your changes
- Update `version` value on `version.rb` file
- To install the package from local codes, you should build a gem `gem build veritrans.gemspec` after that `gem install veritrans-x.y.z.gem` (replace `x.y.z` with the version number e.g. `gem install veritrans-2.4.0.gem`)
  - Note: In case you want to test another new code changes, you will need to re-build & re-install, so that your latest code will be used by the locally installed gem
- To run all test `cd /lib/test` and after that `ruby -Itest all.rb`
- To run specific test `ruby snap_test.rb`
- If you are using Rubymine, you can right click folder test and choose `run all tests in test`

## Update Rubygems.org
- Run this command `gem build veritrans.gemspec`
- Run this command `gem push veritrans-x.y.z.gem` (replace `x.y.z` with the version number e.g. `gem push veritrans-2.4.0.gem`), after that you are required to enter email and password account in Rubygems.org
- You can get account Rubygems.org in `Account Access & Resources`
- If you are using Rubymine, you can use `Tools -> Gem -> Build Gem` and `Push Gem`