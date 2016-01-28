require 'spec_helper'

describe "example" do

  let(:file) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'test_document.xml')) }
  let(:xml) { Nokogiri::XML(file) }

  subject do
     xml.set_terminology(:namespaces => { 'mods' => 'http://www.loc.gov/mods/v3'}) do |t|

       # NOTE ---------------------------------------------------------------------------------
       t.note :path => '/mods/note'
       t._note :path => '//note' do |n|
         n.displayLabel :path => '@displayLabel', :accessor => lambda { |a| a.text }
         n.id_at :path => '@ID', :accessor => lambda { |a| a.text }
         n.type_at :path => '@type', :accessor => lambda { |a| a.text }
       end
     end

     xml.nom!
     xml
  end

  it "should work" do
    expect(subject.note).not_to be_empty
  end
end
