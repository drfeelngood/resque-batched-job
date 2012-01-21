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

  def test_encoding
    Resque.enqueue(Job, @batch_id, 123)
    Resque.enqueue(JobWithoutArgs, @batch_id)

    assert_equal("{\"class\":\"Job\",\"args\":[123]}", redis.lindex(@batch, 0))
    assert_equal("{\"class\":\"JobWithoutArgs\",\"args\":[]}", redis.lindex(@batch, 1))
  end

  def test_batch_key
    assert_nothing_raised do
      Resque.enqueue(Job, @batch_id, 'foobar')
    end
    assert_equal(@batch, Job.batch(@batch_id))
  end

  # Ensure the length of the Redis list matches the number of jobs we enqueue.
  def test_batch_size
    assert_nothing_raised do
      5.times { Resque.enqueue(Job, @batch_id, "arg#{rand(100)}") }
    end
    assert_equal(5, redis.llen(@batch))
  end

  # Make sure the after_batch hook is fired
  def test_batch_hook
    assert_equal(false, Job.batch_exist?(@batch_id))
    
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

  # Test that jobs with identical args behave properly.
  def test_duplicate_args
    assert_equal(false, Job.batch_exist?(@batch_id))

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

  # Make sure the block is executed and the lock is removed.
  def test_mutex
    Job.send(:mutex, @batch_id) do
      assert(true)
    end
    assert_equal(false, redis.exists("#{@batch}:lock"))
  end

  # Make sure no race conditions occur.
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

  def test_remove_batched_job
    Resque.enqueue(JobWithoutArgs, @batch_id)

    assert_nothing_raised do
      JobWithoutArgs.remove_batched_job(@batch_id)
    end
    assert(Job.batch_complete?(@batch_id))
    assert_equal(false, Job.batch_exist?(@batch_id))
    assert_equal(false, $batch_complete)

    Resque.enqueue(JobWithoutArgs, @batch_id)

    assert_nothing_raised do
      JobWithoutArgs.remove_batched_job!(@batch_id)
    end
    assert($batch_complete)
    assert(Job.batch_complete?(@batch_id))
    assert_equal(false, Job.batch_exist?(@batch_id))
  end

  def test_enqueue_batched_job
    Resque.enqueue_batched_job(JobWithoutArgs, @batch_id)
    assert(Job.batch_exist?(@batch_id))
  end

  private

    def redis
      Resque.redis
    end

end