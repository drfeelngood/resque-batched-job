require 'rubygems'
require 'test/unit'
require 'resque'
require 'resque-batched-job'

class Job
  extend Resque::Plugins::BatchedJob
  @queue = :test
  
  def self.perform(batch_id, arg)
  end
  
  def self.after_batch_hook(batch_id, arg)
    $batch_complete = true
  end
  
end

class BatchedJobTest < Test::Unit::TestCase
  
  def setup
    $batch_complete = false
    @batch_id = :foo
    @batch = "batch:#{@batch_id}"
    @cnt = 5
    @cnt.times { Resque.enqueue(Job, @batch_id, "arg#{rand(100)}") }
  end
  
  def teardown
    redis.del(@batch)
    redis.del("queue:test")
  end
  
  def test_list
    assert_nothing_raised do
      Resque::Plugin.lint(Resque::Plugins::BatchedJob)
    end
  end
  
  def test_batch_key
    assert_equal(@batch, Job.batch(@batch_id))
  end
  
  def test_batch_size
    # assert_equal(@cnt, redis.smembers(@batch).size)
    assert_equal(@cnt, redis.llen(@batch))
  end
  
  def test_batch_hook
    assert_nothing_raised do
      @cnt.times { Resque.reserve(:test).perform }
    end
    assert($batch_complete)
    assert_equal(false, redis.exists(@batch))
  end

  private

    def redis
      Resque.redis
    end
    
end