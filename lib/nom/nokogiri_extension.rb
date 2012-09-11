module Nom
  module NokogiriExtension

    def nom!
      unless decorators(Nokogiri::XML::Node).include? Nom::Decorators::Terminology
        decorators(Nokogiri::XML::Node) << Nom::Decorators::Terminology
        decorate!
      end

      self
    end
  end
end
