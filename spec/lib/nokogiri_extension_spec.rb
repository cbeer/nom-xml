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
  describe "#add_terminology_methods" do
    context "root node" do
      it "should add terminology methods to the root node" do

      end
    end
  end
end
