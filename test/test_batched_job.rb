$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'resque'
require 'resque/plugins/batched_job'

class BatchedJobTest < Test::Unit::TestCase
  
  def test_list
    assert_nothing_raised do
      Resque::Plugin.lint(Resque::Plugins::BatchedJob)
    end
  end
    
end