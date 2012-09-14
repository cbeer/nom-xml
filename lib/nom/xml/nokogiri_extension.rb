require 'active_support/core_ext/array'

module Nom::XML
  module NokogiriExtension

    def nom!
      unless decorators(Nokogiri::XML::Node).include? Nom::XML::Decorators::Terminology
        decorators(Nokogiri::XML::Node) << Nom::XML::Decorators::Terminology
        decorate!
      end

      unless decorators(Nokogiri::XML::NodeSet).include? Nom::XML::Decorators::NodeSet
        decorators(Nokogiri::XML::NodeSet) << Nom::XML::Decorators::NodeSet
        decorate!
      end

      self
    end

    def set_terminology options = {}, &block
      @terminology_namespaces = options[:namespaces]
      @terminology = Nom::XML::Terminology.new &block
    end

    def terminology_namespaces
      @terminology_namespaces ||= {}
    end

    def terminology
      @terminology ||= Nom::XML::Terminology.new
    end

  end
end
