require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

$:.unshift(File.dirname(__FILE__))

task :default => :test

Rake::TestTask.new do |task|
  task.libs << 'lib'
  task.pattern = 'test/test_*.rb'
  task.verbose = true
end