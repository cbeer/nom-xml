require 'spec_helper'

describe Nom::VERSION do
  it "should be 0.0.1" do
    Nom::VERSION.should == '0.0.1'
  end

  it "should do stuff with terminologies" do
    doc = Nokogiri::XML <<-eos
  <root>
  <element_a>a value</element_a>
  <element_b>
    <element_c>c value</element_c>
  </element_b>
  </root>
    eos

    doc.set_terminology do |t|
      t.element_a
      t.element_b do |n|
        n.element_c
      end
    end

    doc.nom!

    doc.root.element_a.text.should == 'a value'
    doc.root.element_b.first.element_c.text.should == 'c value'
  end
end
