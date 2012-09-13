module Nom::XML::Decorators::NodeSet
	def method_missing sym, *args, &block
		if self.all? { |node| node.respond_to? sym }
			result = self.collect { |node| node.send(sym, *args, &block) }.flatten
			self.class.new(self.document, result) rescue result
		else
			super
		end
	end
end
