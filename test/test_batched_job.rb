$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
# require 'test/unit'
require 'resque'
require 'resque/plugins/batched_job'

module TestHooks

  def after_batch_celebrate(id, *args)
    "batch #{id} is complete!"
  end
  
end

class TestJob
  
  extend Resque::Plugins::BatchedJob
  extend TestHooks
  
  @queue = :test
  
  def self.perform(batch_id, arg)
    sleep 1
  end
  
end

# class BatchedJobTest < Test::Unit::TestCase
#   
#   def test_list
#     assert_nothing_raised do
#       Resque::Plugin.lint(Resque::Plugins::BatchedJob)
#     end
#   end
#   
#   def test_batched_job
#     for i in 1000..1010 do
#       4.times { Resque.enqueue(TestJob, i) }
#     end
#     worker = Resque::Worker.new(:test)
#     worker.work
#   end
#   
# end

for i in 1000..1001 do
  puts i
  4.times { puts "enqueue => #{i}"; Resque.enqueue(TestJob, i, rand(1000)) }
end
worker = Resque::Worker.new(:test)
worker.verbose = true
worker.very_verbose = true
worker.work

