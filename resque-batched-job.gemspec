$:.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'lib/resque/plugins/batched_job/version'

Gem::Specification.new do |s|
  
  s.name        = "resque-batched-job"
  s.version     = "#{Resque::Plugins::BatchedJob::VERSION}"
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.homepage    = "https://github.com/drfeelngood/resque-batched-job"
  s.authors     = ["Daniel Johnston"]
  s.email       = "dan@dj-agiledev.com"
  
  s.summary     = "Resque plugin"
  s.description = <<-DESC
  Resque plugin for batching jobs. When a batch/group of jobs are complete, 
additional work can be performed usings batch hooks.
DESC

  s.add_dependency "resque", ">= 1.10.0"

  s.files       = %w(LICENSE Rakefile README.md)
  s.files      += Dir.glob("lib/**/*")
  s.test_files += Dir.glob("test/test_*")

end