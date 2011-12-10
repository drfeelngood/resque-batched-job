require 'rubygems'
require 'rake'
require 'rake/testtask'

require File.dirname(__FILE__) + '/lib/resque/plugins/batched_job/version'

task :default => :test

Rake::TestTask.new do |task|
  task.pattern = 'test/test_*.rb'
  task.verbose = true
end

desc "Publish RubyGem and source."
task :publish => [:build, :tag] do
  sh "git push origin v#{Resque::Plugins::BatchedJob::VERSION}"
  sh "git push origin master"
  sh "gem push resque-batched-job-#{Resque::Plugins::BatchedJob::VERSION}.gem"
end

desc "Tag project with current version."
task :tag do
  sh "git tag v#{Resque::Plugins::BatchedJob::VERSION}"
end

desc "Build RubyGem."
task :build do
  sh "gem build resque-batched-job.gemspec"
end

desc "View changelog"
task :changelog do
  tags = `git tag`.split("\n").reverse

  tags.each_slice(2) do |tags|
    puts "========== #{tags[1]}..#{tags[0]} =========="
    sh "git log --pretty=format:'%h : %s' --graph #{tags[1]}..#{tags[0]}"
  end
end
