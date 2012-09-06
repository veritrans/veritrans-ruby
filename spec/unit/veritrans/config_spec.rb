require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Veritrans::Config do
  before do
    Object.send(:remove_const, :Tmp_class) if Object.const_defined?(:Tmp_class)
    Tmp_class = Class.new
  end

  describe "check include module" do
    it "return development mode" do
      klass = nil
      if Object.const_defined?(:Rails)
        klass = Rails
        Object.send(:remove_const, :Rails) 
      end
      Tmp_class.send(:include, Veritrans::Config)
      Tmp_class.class_eval("@@config_env").must_equal('development')
      Rails = klass if klass
    end

    it "return mode from Rails.env" do
      klass = nil 
      if !::Object.const_defined?(:Rails)
        klass = Class.new 
        Rails = klass
        def Rails.env
        end
      end
      Rails.stub(:env, 'production') do 
        Tmp_class.send(:include, Veritrans::Config)
        Tmp_class.class_eval("@@config_env").must_equal('production')
      end
      Object.send(:remove_const, :Rails) if klass
    end
  end
end