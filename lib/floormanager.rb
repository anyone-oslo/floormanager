module FloorManager
  if defined?(::BasicObject)
    BasicObject = ::BasicObject #:nodoc:
  else
    class BasicObject #:nodoc:
      instance_methods.each{|m| undef_method m unless m =~ /^__|instance_eval/}
    end
  end
end

require 'thread'
require 'floormanager/states'
require 'floormanager/queue'
require 'floormanager/workers'
require 'floormanager/result'
