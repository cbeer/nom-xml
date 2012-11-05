module Nom::XML
  class Terminology < Term

    def initialize options = {}, *args, &block
      @terms = {}
      @options = options || {}
      in_edit_context do
        yield(self) if block_given?
      end
    end

    def namespaces
      options[:namespaces] || {}
    end

    def xpath
      nil
    end
  end
end
