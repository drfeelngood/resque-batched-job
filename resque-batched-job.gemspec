$:.unshift(File.dirname(__FILE__))
require 'lib/resque/plugins/batched_job/version'

Gem::Specification.new do |s|
  s.name = 'resque-batched-job'
  s.version = Resque::Plugins::BatchedJob::VERSION
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary = 'Resque plugin'
  s.description = <<-EOF
  Resque plugin for batching jobs. When a batch/group of jobs are complete, 
additional work can be performed usings batch hooks.'
EOF
  s.has_rdoc = false
  s.homepage = "http://github.com/djohnston/resque-batched-job"
  s.authors = ["Daniel Johnston"]
  s.email = "dan@dj-agiledev.com"

  s.add_dependency "resque", "~> 1.10.0"

  s.files = %w(LICENSE Rakefile README.markdown)
  s.files += Dir.glob("lib/**/*")
  s.files += Dir.glob("test/*")
end