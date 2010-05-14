require 'httparty'
require 'floormanager'

# = Example Twitter client with robust concurrent search. 
#
# Will handle rate limiting and errors gracefully, optionally
# retrying for a number of times before failing.
#
# == Usage:
# 
#  twitter = Twitter.new(:concurrency => 10, :retries => 5, :retry_delay => 10)
#  results = twitter.concurrent_search(['ruby', 'httparty', 'floormanager'])
#  results.each do |search_string, tweets|
#    unless tweets.failed?
#      puts tweets.inspect
#    end
#  end

class Twitter
	include HTTParty
	
	def initialize(options={})
		@concurrency = options[:concurrency] || 20
		@retries     = options[:retries]     || 0
		@retry_delay = options[:retry_delay] || 2.0
	end
	attr_accessor :concurrency, :retries, :retry_delay

	base_uri       'http://search.twitter.com'
	default_params :rpp => '100'
	format         :json

	def concurrent_search(query_strings)
		queue   = FloorManager::Queue.new(query_strings)
		workers = FloorManager::Workers.new(queue)
		workers.perform(:threads => @concurrency) do |query_string|
			retries = 0
			begin
				results = self.class.get('/search.json', :query => {:q => "#{query_string}"})
				# Handle rate limiting
				if results.code == 420                          
					if result.headers['retry-after']
						retry_delay = result.headers['retry-after'].first.to_i
					else
						retry_delay = @retry_delay
					end
					workers.halt(retry_delay) # Halt all workers for the retry delay
					retry
				else
					results['results']
				end
			rescue Exception => error
				if retries < @retries         # If at first you don't succeed, try and try again
					retries += 1 
					sleep(@retry_delay) and retry
				end
				workers.failed(error)         # Return a failed result after 5 tries
			end
		end
	end
end