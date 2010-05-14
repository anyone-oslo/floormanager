module FloorManager
	class Result < FloorManager::BasicObject
		attr_accessor :result, :state
		attr_reader :delegate

		def initialize(delegate, result, state=States::SUCCESS)
			@delegate = delegate
			@result = result
			@state = state
		end
		
		def method_missing(name, *args, &block)
			@delegate.send(name, *args, &block)
		end
		
		def state
			@state
		end
	
		def failed?
			@state == States::FAILED
		end
	    
		def success?
			@state == States::SUCCESS
		end
	end
end