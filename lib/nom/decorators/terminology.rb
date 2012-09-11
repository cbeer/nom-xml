module Nom::Decorators::Terminology
  def self.extended klass

    klass.add_terminology_methods!
  end

  def terms
    @terms ||= []
  end

  def terms= terms
    @terms = terms
  end

  def add_terminology_methods!
    document.add_terminology_methods(self)
  end

end
