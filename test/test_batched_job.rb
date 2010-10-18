$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
# require 'test/unit'
require 'resque'
require 'resque/plugins/batched_job'

class TestJob # => aka count your toes and put your socks on!
  
  extend Resque::Plugins::BatchedJob

  @queue = :test
  
  def self.perform(foot, toe_num)
    puts "#{toe_num} " + (toe_num==1 ? 'toe' : 'toes')
  end

  def self.after_batch_put_on_sock(foot, toe_num)
    puts "putting sock on #{foot} foot.."
  end

end

=begin
  TODO: understand Test::Unit::TestCase.  kinda sad.
class BatchedJobTest < Test::Unit::TestCase
  
  def test_list
    assert_nothing_raised do
      Resque::Plugin.lint(Resque::Plugins::BatchedJob)
    end
  end
    
end
=end
%w(left right).each do |foot|
  i=0
  10.times { Resque.enqueue(TestJob, foot, i+=1) }  
end

worker = Resque::Worker.new(:test)
worker.verbose = true
# worker.very_verbose = true
worker.work
