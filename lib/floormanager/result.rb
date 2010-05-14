module FloorManager
	class Result < FloorManager::BasicObject
		attr_accessor :result, :state

		def initialize(result, state=States::SUCCESS)
			@result = result
			@state = state
		end
		
		def method_missing(name, *args, &block)
			@result.send(name, *args, &block)
		end
		
		def failed?
			@state == States::FAILED
		end
	    
		def success?
			@state == States::SUCCESS
		end
	end
end