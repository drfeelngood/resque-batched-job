require 'rubygems'
require 'test/unit'
require 'resque'

$:.unshift(File.dirname(__FILE__) + '../lib')

require 'resque/plugins/batched_job'

class Job
  
  extend Resque::Plugins::BatchedJob
  
  @queue = :test
  
  def self.perform(batch_id)
    $stdout.puts "perform batch[#{batch_id}]"
    sleep 1
  end
  
  def self.after_batch_hook(batch_id)
    $stdout.puts "after_bactch [#{batch_id}]"
    sleep 1
  end
  
end

class BatchedJobTest < Test::Unit::TestCase
  
  def test_list
    assert_nothing_raised do
      Resque::Plugin.lint(Resque::Plugins::BatchedJob)
    end
  end
  
  def test_version
    assert_equal('1.10.0', Resque::Version)
  end
  
  def test_batched_job
    5.times { Resque.enqueue(Job, 1, "arg#{rand(100)}") }
    worker = Resque::Worker.new(:test)
    worker.work
  end
    
end