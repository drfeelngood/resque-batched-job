require 'rake/testtask'
require 'rake/rdoctask'

Rake::TestTask.new do |task|
  task.libs << 'lib'
  task.pattern = 'test/test_*.rb'
  task.verbose = true
end

desc "push the shiz to github"
task :publish do
  sh "git push origin master"
end