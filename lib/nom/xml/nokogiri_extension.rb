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

      node.terms.each do |k, t|
        (class << node; self; end).send(:define_method, k.to_sym) do
          if self.is_a? Nokogiri::XML::Document
            result = self.root.xpath(t.local_xpath)
          else
            result = self.xpath(t.local_xpath)
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
