require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Veritrans::HashGenerator do
  it "generate SHA-512" do
    Veritrans::HashGenerator.generate("sample1",
    "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789012345678901","01","72716569","10").
    must_equal("1958d52d70cf885a17093af26e6d0c45c4af299261e09c154eb8da0457eeb03744ba1485a5b29e61583895c938237dc6a7cc6b17b34019d1b08965c4dd542a31")
  end
end