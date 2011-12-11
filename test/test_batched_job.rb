require File.dirname(__FILE__) + '/test_helper'

class BatchedJobTest < Test::Unit::TestCase

  def setup
    $batch_complete = false
    @batch_id = :foo
    @batch = "batch:#{@batch_id}"
  end

  def teardown
    redis.del(@batch)
    redis.del("queue:test")
    redis.del("#{@batch}:lock")
  end

  def test_list
    assert_nothing_raised do
      Resque::Plugin.lint(Resque::Plugins::BatchedJob)
    end
  end

  def test_batch_key
    assert_nothing_raised do
      Resque.enqueue(Job, @batch_id, 'foobar')
    end
    assert_equal(@batch, Job.batch(@batch_id))
  end

  def test_batch_size
    assert_nothing_raised do
      5.times { Resque.enqueue(Job, @batch_id, "arg#{rand(100)}") }
    end
    assert_equal(5, redis.llen(@batch))
  end

  def test_batch_hook
    assert_nothing_raised do
      5.times { Resque.enqueue(Job, @batch_id, "arg#{rand(100)}") }
    end

    assert_equal(false, $batch_complete)
    assert_equal(false, Job.batch_complete?(@batch_id))
    assert(Job.batch_exist?(@batch_id))

    assert_nothing_raised do
      4.times { Resque.reserve(:test).perform }
    end

    assert_equal(false, $batch_complete)
    assert_equal(false, Job.batch_complete?(@batch_id))
    assert(Job.batch_exist?(@batch_id))

    assert_nothing_raised do
      Resque.reserve(:test).perform
    end

    assert($batch_complete)
    assert(Job.batch_complete?(@batch_id))
    assert_equal(false, Job.batch_exist?(@batch_id))
  end

  def test_duplicate_args
    assert_nothing_raised do
      5.times { Resque.enqueue(JobWithoutArgs, @batch_id) }
    end

    assert_equal(false, $batch_complete)
    assert_equal(false, Job.batch_complete?(@batch_id))
    assert(Job.batch_exist?(@batch_id))

    assert_nothing_raised do
      2.times { Resque.reserve(:test).perform }
    end

    assert_equal(false, $batch_complete)
    assert_equal(false, Job.batch_complete?(@batch_id))
    assert(Job.batch_exist?(@batch_id))

    assert_nothing_raised do
      3.times { Resque.reserve(:test).perform }
    end

    assert($batch_complete)
    assert(Job.batch_complete?(@batch_id))
    assert_equal(false, Job.batch_exist?(@batch_id))
  end

  def test_mutex
    Job.send(:mutex, @batch_id) do
      assert(true)
    end
    assert_equal(false, redis.exists("#{@batch}:lock"))
  end
  
  def test_locking
    threads = []
    x, y = 10, 5

    x.times do
      threads << Thread.new do
        y.times do
          Job.send(:mutex, @batch_id) do
            redis.incr(@batch)
          end
        end
      end
    end
    threads.each { |t| t.join }

    assert_equal(x * y, Integer(redis.get(@batch)))
  end

  private

    def redis
      Resque.redis
    end

end