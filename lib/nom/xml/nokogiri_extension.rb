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

    def set_terminology &block
      @terminology = Nom::XML::Terminology.new &block
    end

    def terminology
      @terminology ||= Nom::XML::Terminology.new
    end

    ##
    # Add terminology accessors for querying child terms
    # @param [Nokogiri::XML::Node] node
    def add_terminology_methods node
      terms_to_add = node.terms
      node.ancestors.each do |a|
        a.terms.each { |k,t| terms_to_add[k] ||= t if t.options[:global] }
      end

      terms_to_add.each do |k, t|
        (class << node; self; end).send(:define_method, k.to_sym) do |*args|
          options = args.extract_options!

          args += options.map { |key, value| %{#{key}="#{value.gsub(/"/, '\\\"') }"} }

          xpath = t.local_xpath

          xpath += "[#{args.join('][')}]" unless args.empty?

          result = case self
                     when Nokogiri::XML::Document
                       self.root.xpath(xpath)
                     else
                       result = self.xpath(xpath)
                   end

          m = t.options[:accessor]
          case
          when m.nil?
            result
          when m.is_a?(Symbol)
            result.collect { |r| r.send(m) }
          when m.is_a?(Proc)
            result.collect { |r| m.call(r) }
          else
            raise "Unknown accessor class: #{m.class}"
          end
        end
      end
    end
  end
end
