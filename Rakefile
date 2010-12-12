require 'rubygems'
require 'rake'
require 'rake/testtask'

$:.unshift(File.dirname(__FILE__))

task :default => :test

Rake::TestTask.new do |task|
  task.libs << 'lib'
  task.pattern = 'test/test_*.rb'
  task.verbose = true
end

desc "Publish gem and source."
task :publish => :build do
  require 'lib/resque/plugins/batched_job/version'
  sh "gem push resque-batched-job-#{Resque::Plugins::BatchedJob::VERSION}.gem"
  sh "git tag v#{Resque::Plugins::BatchedJob::VERSION}"
  sh "git push origin v#{Resque::Plugins::BatchedJob::VERSION}"
  sh "git push origin master"
end

desc "Build gem."
task :build do
  sh "gem build resque-batched-job.gemspec"
end
