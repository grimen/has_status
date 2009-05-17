# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{has_status}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jonas Grimfelt"]
  s.date = %q{2009-05-17}
  s.description = %q{The missing status/enum field helpers for ActiveRecord.}
  s.email = %q{grimen@gmail.com}
  s.extra_rdoc_files = [
    "README.textile"
  ]
  s.files = [
    "MIT-LICENSE",
    "README.textile",
    "Rakefile",
    "TODO.textile",
    "lib/has_status.rb",
    "rails/init.rb",
    "test/has_status_test.rb",
    "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/grimen/has_status/tree/master}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{The missing status/enum field helpers for ActiveRecord.}
  s.test_files = [
    "test/has_status_test.rb",
    "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
