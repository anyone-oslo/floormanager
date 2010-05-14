module FloorManager
	class Worker

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
							value = yield(item)
							checkin(item, value)
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
			@mutex.synchronize{@queue.checkout}
		end

		def checkin(*args)
			@mutex.synchronize{@queue.checkin(*args)}
		end

		def synchronize
			@mutex.synchronize{yield}
		end
		alias :exclusively :synchronize
	end
end