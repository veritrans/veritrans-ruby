require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Veritrans::Version do
	it "returns version" do 
    Veritrans::Version.stub(:major, 1) do 
      Veritrans::Version.stub(:minor, 0) do 
        Veritrans::Version.stub(:patch, 0) do 
          Veritrans::Version.to_s.must_equal("1.0.0")
        end
      end
    end
  end
end