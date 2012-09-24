require 'helper'

class TestFloorManager < Test::Unit::TestCase

  context "a processed queue" do
    setup do
      workers = FloorManager::Workers.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
      @results = workers.perform(:threads => 5) do |number|
        number * 10
      end
    end

    should "process a queue" do
      @results.each do |original, result|
        assert_equal (original * 10), result
      end
    end
  end

  context 'a queue with non-unique items' do
    setup do
      @queue = FloorManager::Queue.new(['a', 'a', 'b', 'c'])
    end
    
    should "not hang" do
      FloorManager::Workers.new(@queue).perform(:threads => 5) do |item|
      end
      assert true # The processes will simply hang here if not
    end
  end

end
