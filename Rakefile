require File.expand_path('lib/dashline', File.dirname(__FILE__))
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.pattern = 'test/*_test.rb'
end

task :build do
  `gem build dashline.gemspec`
end

task :clean do
  rm Dir.glob('*.gem')
end

task :push => :build do
  `gem push dashline-#{Dashline::VERSION}.gem`
end
