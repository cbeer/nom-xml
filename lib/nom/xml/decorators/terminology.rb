module Nom::XML::Decorators::Terminology
  
  ##
  # Nom::XML::Decorators::Terminology is mixed into
  # every Nokogiri::XML::Node (See Nom::XML::NokogiriExtension)
  #
  # We need to add terminology-based accessors to the Node
  def self.extended node
    node.add_terminology_methods!
  end

  ##
  # Add methods to access child terms (defined by the document's terminology)
  def add_terminology_methods!
    self.term_accessors.each do |k, t|
      (class << self; self; end).send(:define_method, k.to_sym) do |*args|
        options = args.extract_options!

        args += options.map { |key, value| %{#{key}="#{value.gsub(/"/, '\\\"') }"} }

        xpath = t.local_xpath

        xpath += "[#{t.options[:if]}]" if t.options[:if] and t.options[:if].is_a? String
        xpath += "[not(#{t.options[:unless]})]" if t.options[:unless] and t.options[:unless].is_a? String

        xpath += "[#{args.join('][')}]" unless args.empty?

        result = case self
                   when Nokogiri::XML::Document
                     self.root.xpath(xpath, self.document.terminology_namespaces)
                   else
                     self.xpath(xpath, self.document.terminology_namespaces)
                 end

        result = result.select &t.options[:if] if t.options[:if].is_a? Proc
        result = result.reject &t.options[:unless] if t.options[:unless].is_a? Proc

        m = t.options[:accessor]
        return_value = case
          when m.nil?
            result
          when m.is_a?(Symbol)
            result.collect { |r| r.send(m) }.compact
          when m.is_a?(Proc)
            result.collect { |r| m.call(r) }.compact
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
  # Get the terms associated with this node
  def terms
    @terms ||= self.ancestors.map { |p| p.term_accessors(self).values }.flatten.compact.uniq
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
end
