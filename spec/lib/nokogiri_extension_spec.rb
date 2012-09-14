require 'spec_helper'

describe Nom::XML::NokogiriExtension do
  let(:doc) {
    Nokogiri::XML(<<-eoxml)
      <item>
        <title>foo</title>
        <description>this is the foo thing</description>
        <nested>
          <second_level>value</second_level>

          <further_nesting>
            <third_level>3rd</third_level>
          </further_nesting>
        </nested>
      </item>
    eoxml
  }

  describe "#nom!" do
    it "should decorate Nodes and Nodesets with our decorators" do
      doc.nom!

      doc.root.should be_a_kind_of(Nom::XML::Decorators::Terminology)

      doc.xpath('//*').should be_a_kind_of(Nom::XML::Decorators::NodeSet)
    end
  end
end
