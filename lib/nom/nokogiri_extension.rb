module Nom
  module NokogiriExtension

    def nom!
      unless decorators(Nokogiri::XML::Node).include? Nom::Decorators::Terminology
        decorators(Nokogiri::XML::Node) << Nom::Decorators::Terminology
        decorate!
      end

      self
    end

    def set_terminology &block
      remove_terminology_methods
      @terminology = Nom::XML::Terminology.new &block
      build_terminology_methods
    end

    def terminology
      @terminology ||=  begin
                          t = Nom::XML::Terminology.new
                          build_terminology_methods
                          t
                        end
    end

    def remove_terminology_methods
    end

    def build_terminology_methods
    end

    def add_terminology_methods node
      return unless node.respond_to? :parent

      if node == node.document.root
        node.terms = node.document.terminology.terms
      elsif not node.parent.terms.empty?
        h = {}
        t = node.parent.terms.select do |k,term|
          node.parent.xpath(term.xpath).include? node
        end
        t.each do |k,v|
          v.terms.each do |k1, v1|
            h[k1] = v1
          end
        end

        node.terms = h
      end

      node.terms.each do |k, t|
        node.instance_eval <<-eos
          def #{k}
            self.xpath "#{t.local_xpath}"
          end
        eos
      end
    end
  end
end
