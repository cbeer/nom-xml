require 'spec_helper'

describe "Nutrition" do
  let(:file) {
    <<-eoxml
  <root>
    <a>1234</a>

    <b>asdf</b>

    <c>
      <nested>poiuyt</nested>
    </c>
  </root>
   eoxml
  }
  let(:xml) { Nokogiri::XML(file) }

  let(:document) {
     xml.set_terminology do |t|
       t.a
       t.b
       t.b_ref :path => 'b'

       t.c do |c|
         c.nested
       end

       t.d :if => 'my-custom-function()'
     end

     xml.nom!

     xml
  }

  describe "#add_terminology_method_overrides!" do

    it "should warn you if you try to override already existing methods" do
      mock_term = {:text => mock(:options => {})}
      document.a.first.stub(:term_accessors).and_return mock_term
      expect { document.a.first.add_terminology_method_overrides! }.to raise_error /Trying to redefine/
    end
  
    it "should let you override the warning" do
      mock_term = {:text => mock(:options => { :override => true } )}
      document.a.first.stub(:term_accessors).and_return mock_term
      expect { document.a.first.add_terminology_method_overrides! }.to_not raise_error /Trying to redefine/
    end
  end

  describe "#values_for_term" do
    it "should call the method of the same name as a Symbol" do
      mock_term = mock(:options => { :accessor => :text })
      document.a.first.value_for_term(mock_term).should == '1234'
    end
    it "should evaluate a Proc" do
      mock_term = mock(:options => { :accessor => lambda { |x| x.name } })
      document.a.first.value_for_term(mock_term).should == 'a'
    end
  end

  describe "#terms" do

    context "root element" do
      subject { document.root }

      it "should not have any associated terminology terms" do
        subject.terms.should be_empty
      end

    end

    context "node with a single term" do
      subject { document.xpath('//a').first }

      it "should have a single term" do
        subject.terms.should have(1).item
      end

      it "should find the right term" do
        subject.terms.map { |x| x.name }.should include(:a)
      end
    end

    context "node with multiple terms" do
      subject { document.xpath('//b').first }

      it "should have multiple terms" do
        subject.terms.should have(2).items
      end

      it "should find the right terms" do
        subject.terms.map { |x| x.name }.should include(:b, :b_ref)
      end
    end
  end

  describe "#term_accessors" do

    context "node" do
      subject { document.xpath('//c').first }

      it "should have a child accessor" do
        subject.send(:term_accessors).keys.should include(:nested)
      end
    end

    context "document" do
      subject { document }

      it "should have all the root terms" do
        subject.send(:term_accessors).keys.should include(:a, :b, :c)
      end
    end

   context "root node" do
      subject { document.root }

      it "should have all the root terms" do
        subject.send(:term_accessors).keys.should include(:a, :b, :c)
      end
    end
  end


end

