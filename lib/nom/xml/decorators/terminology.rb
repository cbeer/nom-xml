module Nom::XML::Decorators::Terminology
  def self.extended klass

    klass.add_terminology_methods!
  end

  ##
  # Add terminology accessors for querying child terms
  def add_terminology_methods!
    self.term_accessors.each do |k, t|
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
        return_value = case
          when m.nil?
            result
          when m.is_a?(Symbol)
            result.collect { |r| r.send(m) }
          when m.is_a?(Proc)
            result.collect { |r| m.call(r) }
          else
            raise "Unknown accessor class: #{m.class}"
        end


        if return_value and (t.options[:single] or (return_value.length == 1 and return_value.first.is_a? Nokogiri::XML::Attr))
          return return_value.first
        end

        return return_value
      end
    end

    self
  end

  ##
  # Get the terminology terms associated with this node
  def terms
    return {} unless self.respond_to? :parent and not self.parent.term_accessors.empty?

    self.parent.term_accessors.select do |k,term|
      self.parent.xpath(term.local_xpath, self.document.terminology_namespaces).include? self
    end
  end

  protected
  ##
  # Collection of salient terminology accessors for this node
  def term_accessors
    case
      when (self == self.document.root or self.is_a? Nokogiri::XML::Document)
        root_terms
      else
        child_terms
    end
  end

  private

  ##
  # Root terms for the document
  def root_terms
    self.document.terminology.terms
  end

  ##
  # Terms that are immediate children of this node, or are globally applicable
  def child_terms
    h = {}

    terms.each do |k,term|

      term.terms.each do |k1, v1|
        h[k1] = v1
      end
    end

    self.ancestors.each do |a|
      a.term_accessors.each { |k,t| h[k] ||= t if t.options[:global] }
    end

    h
  end
end
