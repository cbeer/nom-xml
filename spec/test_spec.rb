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

describe Nom do
  ### High level goals
  #Given a tree like:
  # <level1> 
  #   <level2 id="parent1">
  #     <level3 id="target1"/>
  #     <level3 id="target1"/>
  #   </level2>
  #   <level2 id="parent2">
  #     <level3 id="target3"/>
  #   </level2>
  # </level1>

  it "Should be able to query for all the 'level3' nodes (leafs with different parents)" 
  it "Should be able to query for all the 'level3' nodes that are children of parent1 (leafs with same parent)" 
  it "Should be able to query for the nth child of a specific node"
  it "Should be able to update the inner text of a specific target node"
  it "Should be able to update the inner texts of a bunch of nodes????? (e.g. find('level2 > level3').innerText=['one', 'two', 'three']"
  it "Should be able to add a subtree at a specific point in the graph"
  it "Should be able to remove a subtree from the graph"
  it "should be able to set the text content of a node to nil"
 
end
