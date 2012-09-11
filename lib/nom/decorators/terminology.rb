module Nom::Decorators::Terminology
  def self.extended klass

    klass.add_terminology_accessors!
  end

  def add_terminology_accessors!
    document.add_terminology_accessors(self)
  end
end
