Resque Batched Job
==================

A [Resque](http://github.com/defunkt/resque) plugin. Requires Resque 1.10.0

TODO
----
	* Define a complete batch

Example
-------

class Job
  
  extend Resque::Plugins::BatchedJob
  
  @queue = :example
  
  def self.before_perform_turn_computer_off(place, name)
    puts "#{name} straightening up desk"
  end
  
  def self.perform(place, name)
    puts "#{name} leaving the #{place}"
    sleep 1
  end
  
  def self.after_batch_turn_lights_out(place, name)
    puts "#{name} turing the lights out in the #{place}."
    sleep 1
  end
  
end