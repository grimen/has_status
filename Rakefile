require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

NAME = "has_status"
SUMMARY = %Q{}
HOMEPAGE = "http://github.com/grimen/#{NAME}/tree/master"
AUTHOR = "Jonas Grimfelt"
EMAIL = "grimen@gmail.com"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = NAME
    gem.summary = SUMMARY
    gem.description = SUMMARY
    gem.homepage = HOMEPAGE
    gem.author = AUTHOR
    gem.email = EMAIL
    
    gem.require_paths = %w{lib}
    gem.files = %w(MIT-LICENSE README.textile TODO.textile Rakefile) + Dir.glob(File.join('{lib,rails,tasks,test}', '**', '*'))
    gem.executables = %w()
    gem.extra_rdoc_files = %w{README.textile}
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc %Q{Run unit tests for "#{NAME}".}
task :default => :test

desc %Q{Run unit tests for "#{NAME}".}
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  desc %Q{Analyze test coverage of the code in "#{NAME}".}
  Rcov::RcovTask.new do |t|
    t.libs << 'test'
    t.test_files = FileList['test/**/*_test.rb']
    t.verbose = true
  end
rescue LoadError
  puts "RCov is not available. In order to run RCov, you must install it: sudo gem install spicycode-rcov -s http://gems.github.com"
end

desc %Q{Generate documentation for "#{NAME}".}
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = NAME
  rdoc.options << '--line-numbers' << '--inline-source' << '--charset=UTF-8'
  rdoc.rdoc_files.include('README.textile')
  rdoc.rdoc_files.include(File.join('lib', '**', '*.rb'))
end