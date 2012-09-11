require 'spec_helper'

describe Nom::VERSION do
  it "should be 0.0.1" do
    Nom::VERSION.should == '0.0.1'
  end

  it "should do stuff" do
    doc = Nokogiri::XML <<-eos
<a>
  <b>c</b>
  </a>
    eos

    doc.nom!

    doc.xpath('//b').first.a.should == "!!!"


  end
end
