describe Veritrans do

  after do
    Veritrans.logger = nil
    Veritrans.file_logger = nil
  end

  it "should set logger" do
    Veritrans.logger = :nothing
    Veritrans.logger.should == :nothing

    Veritrans.file_logger = :nothing2
    Veritrans.file_logger.should == :nothing2
  end

  describe "widthout rails" do
    before do
      hide_const("Rails")
    end

    it "should log to stdout when there is no rails" do
      Veritrans.logger.instance_variable_get(:@logdev).dev.should == $stdout
    end

    it "should set file_logger" do
      Veritrans.file_logger.instance_variable_get(:@logdev).filename.should == "/dev/null"
    end

  end

  describe "width rails" do
    before do
      FileUtils.mkdir_p("/tmp/log")
      allow(Rails).to receive(:logger).and_return(Logger.new(STDERR))
      allow(Rails).to receive(:root).and_return(Pathname.new("/tmp"))
    end

    it "should use rails logger" do
      Veritrans.logger.should == Rails.logger
    end

    it "should set file_logger" do
      Veritrans.file_logger.instance_variable_get(:@logdev).filename.should == "/tmp/log/veritrans.log"
    end
  end
end