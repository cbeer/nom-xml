module Nom::XML::Decorators::NodeSet
	
	##
	# Add a #method_missing handler to NodeSets. If all of the elements in the Nodeset
	# respond to a method (e.g. if it is a term accessor), call that method on all the
	# elements in the node
	def method_missing sym, *args, &block
		if self.all? { |node| node.respond_to? sym }
			result = self.collect { |node| node.send(sym, *args, &block) }.flatten
			self.class.new(self.document, result) rescue result
		else
			super
		end
	end

	def respond_to? sym
      if self.all? { |node| node.respond_to? sym }
      	true
      else
      	super
      end
	end
end
