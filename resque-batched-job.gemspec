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
  
  s.homepage = 'http://github.com/djohnston/resque-batched-job'
  s.authors = ['Daniel Johnston']
  s.email = 'dan@dj-agiledev.com'

  s.add_dependency "resque", "~> 1.10.0"

  s.extra_rdoc_files = ["LICENSE", "README.markdown"]
  s.rdoc_options = ["--charset=UTF-8"]
  
  s.files = %w(
    example
    example/job.rb
    example/Rakefile
    LICENSE
    Rakefile
    README.markdown
    resque-batched-job.gemspec
    lib/resque/plugins/batched_job.rb
    lib/resque/plugins/batched_job/version.rb
    test/test_batched_job.rb
  )
  
end