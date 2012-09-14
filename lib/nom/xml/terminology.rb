module Nom::XML
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
