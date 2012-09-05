require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Veritrans do
  it "doesn't produce warnings if loading veritrans.rb twice" do
    lib_dir = File.expand_path(File.dirname(__FILE__) + "/../../lib")
    veritrans_file = "#{lib_dir}/veritrans.rb"
    File.exist?(veritrans_file).must_equal true
    output = `ruby -r rubygems -I #{lib_dir} -e 'load #{veritrans_file.inspect}; load #{veritrans_file.inspect}' 2>&1`
    output.must_equal ""
  end
end
