module FloorManager
	class Queue
		include Enumerable

		# States
		PENDING     = 0
		CHECKED_OUT = 1
		FAILED      = 2
		SUCCESS     = 3
	
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
					:state => PENDING
				}
			end
			alias :<< :add
	
			# Get the value of an item in the queue
			def get_value(key)
				(item = get_item(key)) ? item[:value] : nil
			end
			alias :[] :get_value
	
			# Returns all the items in the queue
			def keys
				@queue.map{|i| i[:item]}
			end

			# Returns each item with value, hash style
			def each
				@queue.each{|item| yield item[:item], item[:value]}
			end
		
			# Check out an item from the queue
			def checkout
				if pending?
					item = pending_items.first
					item[:state] = CHECKED_OUT
					item[:item]
				else
					nil
				end
			end

			# Check in an item with a new value, optionally with a state
			# (which defaults to SUCCESS)
			def checkin(item, value, state=SUCCESS)
				if keys.include?(item)
					item = get_item(item)
					item[:value] = value
					item[:state] = state
				else
					invalid_key!
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

			# Get the state of an item
			def state(key)
				(item = get_item(key)) ? item[:state] : invalid_key!
			end

			# Is this item processed?
			def processed?(key)
				state(key) > PENDING
			end
		
			# Is this item checked out?
			def checked_out?(key)
				state(key) == CHECKED_OUT
			end

			# Did this item fail?
			def failed?(key)
				state(key) == FAILED
			end

			# Did this item succeed?
			def success?(key)
				state(key) == SUCCESS
			end

			# Is this item completed?
			def completed?(key)
				state(key) >= FAILED
			end

		private

			# Handle invalid keys
			def invalid_key!
				raise ArgumentError, "Invalid key: #{item.inspect}"
			end

			# Get an item by key
			def get_item(key)
				matches = @queue.select{|i| i[:item] == key}
				(matches.length > 0) ? matches.first : nil
			end

			# Get all pending items
			def pending_items
				@queue.select{|i| i[:state] == PENDING}
			end

			# Get all items which are checked out
			def checked_out_items
				@queue.select{|i| i[:state] == CHECKED_OUT}
			end

			# Get all completed items (both failed and successed)
			def completed_items
				@queue.select{|i| i[:state] >= FAILED}
			end

			# Get all failed items
			def failed_items
				@queue.select{|i| i[:state] == FAILED}
			end

			# Get all successed items
			def successed_items
				@queue.select{|i| i[:state] == SUCCESS}
			end

	end
end