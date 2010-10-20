class Job
  
  extend Resque::Plugins::BatchedJob
  
  @queue = :example
  
  def self.before_perform_clean_up(place, name)
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