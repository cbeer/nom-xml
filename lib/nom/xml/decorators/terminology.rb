module Nom::XML::Decorators::Terminology
  def self.extended klass

    klass.add_terminology_methods!
  end

  ##
  # Add terminology accessors for querying child terms
  def add_terminology_methods!
    terms_to_add = self.terms
    self.ancestors.each do |a|
      a.terms.each { |k,t| terms_to_add[k] ||= t if t.options[:global] }
    end

    terms_to_add.each do |k, t|
      (class << self; self; end).send(:define_method, k.to_sym) do |*args|
        options = args.extract_options!

        args += options.map { |key, value| %{#{key}="#{value.gsub(/"/, '\\\"') }"} }

        xpath = t.local_xpath

        xpath += "[#{args.join('][')}]" unless args.empty?

        result = case self
                   when Nokogiri::XML::Document
                     self.root.xpath(xpath, self.document.terminology_namespaces)
                   else
                     self.xpath(xpath, self.document.terminology_namespaces)
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

    self
  end

  def terms
    if self == self.document.root or self.is_a? Nokogiri::XML::Document
      root_terms
    elsif not self.parent.terms.empty?
      child_terms
    else
      []
    end
  end

  private

  def root_terms
    self.document.terminology.terms
  end

  def child_terms
    h = {}

    collect_terms_for_node.each do |k,v|
      v.terms.each do |k1, v1|
        h[k1] = v1
      end
    end

    h
  end

  ##
  #find this self in the terminology
  def collect_terms_for_node
    self.parent.terms.select do |k,term|
      self.parent.xpath(term.local_xpath, self.document.terminology_namespaces).include? self
    end
  end

end
