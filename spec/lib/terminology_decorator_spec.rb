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
     end

     xml.nom!

     xml
  }

  describe "#add_terminology_methods!" do
    subject do
      m = mock()
      m.stub(:document).and_return(mock(:terminology_namespaces => {}))
      m.stub(:term_accessors).and_return(@term_accessors)
      m.extend Nom::XML::Decorators::Terminology
      m
    end

    it "should define terminology accessors" do
      mock_term = mock
      @term_accessors = { :asdf => mock_term }

      subject.should respond_to(:asdf)
    end

    it "should perform basic xpath queries" do
      mock_term = mock(:local_xpath => '//asdf', :options => {})
      @term_accessors = { :asdf => mock_term }

      subject.should_receive(:xpath).with('//asdf', anything)

      subject.asdf
    end

    it "should perform xpath queries with constraints" do
      mock_term = mock(:local_xpath => '//asdf', :options => {})
      @term_accessors = { :asdf => mock_term }

      subject.should_receive(:xpath).with('//asdf[predicate="value"]', anything)
      subject.should_receive(:xpath).with('//asdf[predicate="\"value\""]', anything)
      subject.should_receive(:xpath).with('//asdf[custom-xpath-predicate()]', anything)
      subject.should_receive(:xpath).with('//asdf[custom-xpath-predicate()][predicate="value"]', anything)

      subject.asdf(:predicate => 'value')
      subject.asdf(:predicate => '"value"')
      subject.asdf('custom-xpath-predicate()')
      subject.asdf('custom-xpath-predicate()', :predicate => 'value')
    end

    it "should execute accessors" do
      mock_term = mock(:local_xpath => '//asdf', :options => {:accessor => :text })
      @term_accessors = { :asdf => mock_term }

      m = mock()
      subject.should_receive(:xpath).with('//asdf', anything).and_return([m])
      m.should_receive(:text)

      subject.asdf
    end 

    it "should execute proc-based accessors" do
      mock_term = mock(:local_xpath => '//asdf', :options => {:accessor => lambda { |x| x.zxcvb } })
      @term_accessors = { :asdf => mock_term }

      m = mock()
      subject.should_receive(:xpath).with('//asdf', anything).and_return([m])
      m.should_receive(:zxcvb)

      subject.asdf
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
        subject.terms.keys.should include(:a)
      end
    end

    context "node with multiple terms" do
      subject { document.xpath('//b').first }

      it "should have multiple terms" do
        subject.terms.should have(2).items
      end

      it "should find the right terms" do
        subject.terms.keys.should include(:b, :b_ref)
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

