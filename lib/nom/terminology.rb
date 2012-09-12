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

    def terms_from_node node
      terms.select do |k, term|
        node.parent.xpath(term.xpath).include? node
      end.flatten
    end

    def in_edit_context?
      @edit_context
    end

    def parent_xpath
      @parent_xpath ||= self.parent.xpath
    end

    def clear_parent_cache
      @parent_xpath = nil
    end

    def xpath
      [parent_xpath, local_xpath].flatten.compact.join("/")
    end

    def local_xpath
      (options[:path] || name).to_s
    end
    
    def method_missing method, *args, &block 
      if in_edit_context?
        add_term(method, *args, &block)
      elsif key?(method)
        term(method)
    #  else if options[:ref]
    #    resolve_ref_and_return_term(method, *args, &block)
      else
        super
      end
      #terms[method]
    end

    def key? term
      terms.key? term
    end

    def substitute_parent p
      obj = self.dup

      obj.parent = p
      obj.clear_parent_cache

      obj
    end

    protected
    def add_term method, options = {}, *args, &block
      terms[method] = if options[:ref]
        TermRef.new(self, method, options, *args, &block)
      else
        Term.new(self, method, options, *args, &block)
      end
    end

    def term method, *args, &block
      terms[method]
    end
  end

  class TermRef < Term
    def ref
      elements = Array(options[:ref])

      elements.inject(parent) { |memo, mtd| memo.send(mtd) }
    end

    def key? term
      ref.key? term
    end

    def local_xpath
      (options[:path] || ref.local_xpath).to_s
    end

    def method_missing *args, &block
      if in_edit_context?
        super
      else
        ref.method_missing(*args, &block).substitute_parent(self)
      end
    end
  end

  class Terminology < Term
    def initialize *args, &block
      @terms = {}
      in_edit_context do
        yield(self) if block_given?
      end
    end


    def xpath
      nil
    end
  end
end
