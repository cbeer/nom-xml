require 'active_support/core_ext/array'

module Nom::XML
  module NokogiriExtension

    def nom!
      unless decorators(Nokogiri::XML::Node).include? Nom::XML::Decorators::Terminology
        decorators(Nokogiri::XML::Node) << Nom::XML::Decorators::Terminology
      end

      unless decorators(Nokogiri::XML::NodeSet).include? Nom::XML::Decorators::NodeSet
        decorators(Nokogiri::XML::NodeSet) << Nom::XML::Decorators::NodeSet
      end

      unless decorators(Nokogiri::XML::Document).include? Nom::XML::Decorators::TemplateRegistry
        decorators(Nokogiri::XML::Document) << Nom::XML::Decorators::TemplateRegistry
      end

      decorate!
      self
    end

    def set_terminology options = {}, &block
      @terminology_namespaces = options[:namespaces]
      @terminology = Nom::XML::Terminology.new(options, &block)
    end

    def terminology_namespaces
      @terminology_namespaces ||= {}
    end

    def terminology
      @terminology ||= Nom::XML::Terminology.new
    end

    def template_registry
      @template_registry ||= Nom::XML::TemplateRegistry.new
    end

    # Define a new node template with the Nom::XML::TemplateRegistry.
    # * +name+ is a Symbol indicating the name of the new template.
    # * The +block+ does the work of creating the new node, and will receive
    #   a Nokogiri::XML::Builder and any other args passed to one of the node instantiation methods.
    def define_template name, &block
      self.template_registry.define name, &block
    end


  end
end
