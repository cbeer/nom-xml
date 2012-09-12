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
  <element_d>
    <element_e>
      <element_f foo="bar">f value</element_f>
    </element_e>
  </element_d>
  <element_g>
    <element_h>h value 1</element_h>
    <element_h>h value 2</element_h>
  </element_g>
  <element_g>
    <element_h>h value 3</element_h>
  </element_g>
  </root>
    eos

    doc.set_terminology do |t|
      t.element_a
      t.element_b do |n|
        n.element_c
      end
      t.element_d do |n|
        n.element_e do |e|
          e.element_f
          e.thing :path => 'element_f/@foo'
        end
      end
      t.element_g do |n|
        n.element_h
      end
    end

    doc.nom!

    doc.root.element_a.text.should == 'a value'
    doc.root.element_b.element_c.text.should == 'c value'
    doc.root.element_d.element_e.element_f.text.strip.should == 'f value'
    doc.root.element_d.element_e.thing.text.should == 'bar'
    doc.root.element_g.first.element_h.collect(&:text).should == ['h value 1','h value 2']
    doc.root.element_g.element_h.collect(&:text).should == ['h value 1','h value 2','h value 3']
  end
end
