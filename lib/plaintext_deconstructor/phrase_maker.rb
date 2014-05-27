
class Alltext
	attr_accessor :paragraphs
	def initialize(string)
		@fulltext = string
		@paragraphs = string.split(/\n\t/)
		
	end

end
