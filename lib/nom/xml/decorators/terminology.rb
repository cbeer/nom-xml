module Nom::XML::Decorators::Terminology
  def self.extended klass

    klass.add_terminology_methods!
  end

  def add_terminology_methods!
    document.add_terminology_methods(self)
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
