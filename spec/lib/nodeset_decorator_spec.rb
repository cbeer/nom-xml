require 'spec_helper'

describe Nom::XML::Decorators::NodeSet do
  	subject { 
      doc = Nokogiri::XML '<root><a n="1"/><b /><c /></root>'
      doc.nom!
      doc
  	}
  describe "#values_for_term" do


    it "should do if" do
      t = mock(:options => { :if => lambda { |x| false }})

      t1 = mock(:options => { :if => lambda { |x| true }})

      subject.xpath('//*').values_for_term(t).should be_empty
      subject.xpath('//*').values_for_term(t1).should_not be_empty
    end

    it "should do unless" do
      t = mock(:options => { :unless => lambda { |x| false }})

      t1 = mock(:options => { :unless => lambda { |x| true }})

      subject.xpath('//*').values_for_term(t).should_not be_empty
      subject.xpath('//*').values_for_term(t1).should be_empty
    end

    it "should do a nil accessor" do
      t = mock(:options => { :accessor => nil})

      subject.xpath('//*').values_for_term(t).should == subject.xpath('//*')
    end

    it "should do a Proc accessor" do
      t = mock(:options => { :accessor => lambda { |x| 1 }})
      subject.xpath('//a').values_for_term(t).should == [1]
    end

    it "should do a symbol accessor" do
      t = mock(:options => { :accessor => :z})
      subject.xpath('//a').first.should_receive(:z).and_return(1)
      subject.xpath('//a').values_for_term(t).should == [1]
    end

    it "should do single" do
      t = mock(:options => { :single => true})
      subject.xpath('//*').values_for_term(t).should == subject.xpath('//*').first

    end

    it "should treat an attribute as a single" do
      t = mock(:options => { })
      subject.xpath('//@n').values_for_term(t).should be_a_kind_of Nokogiri::XML::Attr

    end
  end

  describe "method missing and respond to" do
    it "should respond to methods on nodes if all nodes in the nodeset respond to the method" do
      subject.xpath('//*').should respond_to :text
    end

    it "should respond to methods on nodes if all nodes in the nodeset respond to the method" do
      subject.xpath('//*').should_not respond_to :text_123
    end

    it "should work" do
      subject.xpath('//*').name.should include("a", "b", "c")
    end
  end
end