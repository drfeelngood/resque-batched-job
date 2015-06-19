require 'rubygems'
require 'test/unit'
require 'thread'
require 'turn/autorun'
require 'resque'

$:.unshift(File.expand_path(File.dirname(__FILE__)) + '/../lib')
require 'resque/batched_job'

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

class MutatingJob
  extend Resque::Plugins::BatchedJob
  @queue = :test

  def self.perform(batch_id, arg)
    arg['oops'] = 'mutated!!'
  end

  def self.after_batch_hook(batch_id, arg)
    $batch_complete = true
  end

end
