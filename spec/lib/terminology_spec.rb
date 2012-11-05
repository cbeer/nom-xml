require 'spec_helper'

describe Nom::XML::Terminology do
  describe "#namespaces" do
    it "should pull the namespaces out of the terminology options" do
      Nom::XML::Terminology.new(nil, :namespaces => { 'asd' => '123'}).namespaces.should == { 'asd' => '123'}
    end

    it "should return an empty hash if no namespace is provided" do
      Nom::XML::Terminology.new.namespaces.should == {}
    end
  end

  describe "#terminology" do
    it "should be an identity function" do
      a = Nom::XML::Terminology.new

      a.terminology.should == a
    end
  end
end