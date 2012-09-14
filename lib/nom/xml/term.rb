module Nom::XML
  class Term
    attr_reader :name
    attr_reader :terms
    attr_reader :parent
    attr_writer :parent
    attr_reader :options

    def initialize parent, name, options = {}, *args, &block
      @name = name
      @terms = {}
      @parent = parent
      @options = options || {}

      in_edit_context do
        yield(self) if block_given?
      end
    end

    def in_edit_context &block
      @edit_context = true
      yield
      @edit_context = false
    end

    def in_edit_context?
      @edit_context
    end

    def parent_xpath
      @parent_xpath ||= self.parent.xpath
    end

    def clear_parent_cache!
      @parent_xpath = nil
    end

    def xpath
      [parent_xpath, local_xpath].flatten.compact.join("/")
    end

    def local_xpath
      ("#{xmlns}:" unless xmlns.blank? ).to_s + (options[:path] || name).to_s
    end

    def xmlns
      (options[:xmlns] if options) || (self.parent.xmlns if self.parent)
    end

    def method_missing method, *args, &block 
      if in_edit_context?
        add_term(method, *args, &block)
      elsif key?(method)
        term(method)
      else
        super
      end
    end

    def key? term
      terms.key? term
    end

    protected
    def add_term method, options = {}, *args, &block
      terms[method] = Term.new(self, method, options, *args, &block)
    end

    def term method, *args, &block
      terms[method]
    end
  end

end