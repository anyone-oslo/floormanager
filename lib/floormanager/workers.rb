module FloorManager
	class Workers

		def initialize(*queue)
			queue = *queue
			@queue = queue.kind_of?(FloorManager::Queue) ? queue : FloorManager::Queue.new(queue)
			@mutex = Mutex.new
		end
		attr_reader :queue

		def perform(options={})
			options = {:threads => 1}.merge(options)
			threads = (0...options[:threads]).to_a.map do |thread_id|
				Thread.new do
					until queue.done?
						if item = checkout
							result = yield(item)
							result = Result.new(result, (result.state rescue States::SUCCESS))
							checkin(item, result, result.state)
						else
							Thread.pass
						end
					end
				end
			end
			threads.each{|t| t.join}
			@queue
		end

		def checkout
			synchronize{@queue.checkout}
		end

		def checkin(*args)
			synchronize{@queue.checkin(*args)}
		end

		def synchronize
			@mutex.synchronize{yield}
		end
		alias :exclusively :synchronize
		
		def halt(time)
			synchronize{sleep(time)}
		end
		
		def result(result, state=States::SUCCESS)
			Result.new(result, state)
		end
		
		def success(result)
			result(result, States::SUCCESS)
		end

		def failed(result=nil)
			result(result, States::FAILED)
		end
	end
end