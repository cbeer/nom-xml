module Nom::XML::Decorators::Terminology
  def method_missing method, *args, &block
    if self.term_accessors[method.to_sym]
      define_term_method(method, self.term_accessors[method.to_sym])

      self.send(method, *args, &block)
    else
      begin
        self.document.template_registry.send(method, self, *args, &block)
      rescue NameError
        super
      end
    end
  end

  def respond_to_without_terms?(method, regular = true)
    methods(regular).include?(method)
  end

# As of ruby 2.0, respond_to includes an optional 2nd arg:
#   a boolean controlling whether private methods are targeted.
# We don't actually care for term accessors (none private).
  def respond_to_missing? method, private = false
    super || self.term_accessors[method.to_sym]
  end

  ##
  # Get the terms associated with this node
  def terms
    @terms ||= self.ancestors.map { |p| p.term_accessors(self).map { |keys, values| values } }.flatten.compact.uniq
  end

  protected
  ##
  # Collection of salient terminology accessors for this node
  #
  # The root note or document node should have all the root terms
  def term_accessors matching_node =  nil
    terms = case
      when (self == self.document.root or self.is_a? Nokogiri::XML::Document)
        root_terms
      else
        child_terms
    end

    terms &&= terms.select { |key, term| term.nodes.include? matching_node } if matching_node

    terms
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

    # collect the sub-terms of the terms applicable to this node
    terms.each do |term|
      term.terms.each do |k1, v1|
        h[k1] = v1
      end
    end

    # and mix in any global terms of this node's ancestors
    self.ancestors.each do |a|
      a.term_accessors.each { |k,t| h[k] ||= t if t.options[:global] }
    end

    h
  end

  def define_term_method method, term
    (class << self; self; end).send(:define_method, method.to_sym) do |*local_args|
      lookup_term(self.term_accessors[method.to_sym], *local_args)
    end
  end

  def lookup_term term, *args
    args = extract_term_options(*args)

    xpath = term.local_xpath

    xpath += "[#{args.join('][')}]" unless args.empty?

    result = case self
               when Nokogiri::XML::Document
                 self.document.root.xpath(xpath, self.document.terminology_namespaces)
               else
                 self.xpath(xpath, self.document.terminology_namespaces)
               end

    result.values_for_term(term)
  end

  def extract_term_options(*args)
    if args.last.is_a? Hash
      h = args.pop

      args + h.map { |key, value| %(#{key}="#{value.gsub(/"/, '\\\"')}") }
    else
      args
    end
  end
end
