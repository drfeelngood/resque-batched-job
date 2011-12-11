require 'rubygems'
require 'test/unit'
require 'thread'

require 'resque'
require File.dirname(__FILE__) + '/../lib/resque-batched-job'

class Job
  extend Resque::Plugins::BatchedJob
  @queue = :test

  def self.perform(batch_id, arg)
  end

  def self.after_batch_hook(batch_id, arg)
    $batch_complete = true
  end

end

class JobWithoutArgs
  extend Resque::Plugins::BatchedJob
  @queue = :test

  def self.perform(id)
  end

  def self.after_batch_hook(id)
    $batch_complete = true
  end

end