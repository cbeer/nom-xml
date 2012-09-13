require 'spec_helper'

describe "Namespaces example" do
  let(:file) { File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', 'xml_namespaces.xml'), 'r') }
  let(:xml) { Nokogiri::XML(file) }

  subject {
     xml.set_terminology(:namespaces => { 'html4' => 'http://www.w3.org/TR/html4/'}) do |t|
       t.table :xmlns => 'html4' do |t|
         t.tr do |tr|
           tr.td
         end
       end
     end

     xml.nom!

     xml
  }

  it "should get nodes" do
    subject.table.tr.td.map { |x| x.text }.should include("Apples", "Bananas")
  end
end
