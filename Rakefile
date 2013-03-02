require File.expand_path('lib/dashes', File.dirname(__FILE__))
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.pattern = 'test/*_test.rb'
end

task :build do
  `gem build dashes.gemspec`
end

task :clean do
  rm Dir.glob('*.gem')
end

task :push => :build do
  `gem push dashes-#{Dashes::VERSION}.gem`
end
