module FloorManager
	class Queue
		include Enumerable

		def initialize(*args)
			@queue = []
			args.each{|a| self << a} if (args = *args)
		end
	
		public

			# Add an item to the queue
			def add(item)
				@queue << {
					:item  => item,
					:value => nil,
					:state => States::PENDING,
					:index => @queue.length
				}
			end
			alias :<< :add
	
			# Get an item in the queue
			def get_item(index)
				@queue[index]
			end
			alias :[] :get_item
	
			# Returns each item with value, hash style
			def each
				@queue.each{|item| yield item[:item], item[:value]}
			end
		
			# Check out an item from the queue
			def checkout
				if pending?
					item = pending_items.first
					item[:state] = States::CHECKED_OUT
					item
				else
					nil
				end
			end

			# Check in an item with a new value, optionally with a state
			# (which defaults to SUCCESS)
			def checkin(item, state=States::SUCCESS)
				if item.kind_of?(Hash) && @queue[item[:index]][:item] == item[:item]
					@queue[item[:index]] = item.merge({:state => state})
				else
					invalid_item!
				end
			end
		
			# Total queue length
			def length
				@queue.length
			end

			# Is the queue done?
			def done?
				(pending.length == 0 && checked_out.length == 0) ? true : false
			end

			# Does this queue have pending items?
			def pending?
				(pending.length > 0) ? true : false
			end
		
			# Get pending items
			def pending
				pending_items.map{|i| i[:item]}
			end
		
			# Get checked out items
			def checked_out
				checked_out_items.map{|i| i[:item]}
			end

			# Get completed items
			def completed
				completed_items.map{|i| i[:item]}
			end

			# Get successed items
			def successed
				successed_items.map{|i| i[:item]}
			end

			# Get failed items
			def failed
				failed_items.map{|i| i[:item]}
			end

		private

			# Handle invalid keys
			def invalid_item!
				raise ArgumentError, "Invalid item: #{item.inspect}"
			end

			# Get an item by key
			def get_item(key)
				matches = @queue.select{|i| i[:item] == key}
				(matches.length > 0) ? matches.first : nil
			end

			# Get all pending items
			def pending_items
				@queue.select{|i| i[:state] == States::PENDING}
			end

			# Get all items which are checked out
			def checked_out_items
				@queue.select{|i| i[:state] == States::CHECKED_OUT}
			end

			# Get all completed items (both failed and successed)
			def completed_items
				@queue.select{|i| i[:state] >= States::FAILED}
			end

			# Get all failed items
			def failed_items
				@queue.select{|i| i[:state] == States::FAILED}
			end

			# Get all successed items
			def successed_items
				@queue.select{|i| i[:state] == States::SUCCESS}
			end

	end
end