# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{baby-bro}
  s.version = "0.0.17"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bill Doughty"]
  s.date = %q{2011-11-29}
  s.default_executable = %q{bro}
  s.description = %q{Baby Bro monitors timestamp changes of files and and estimates time spent actively working in project directories.}
  s.email = %q{billdoughty@capitalthought.com}
  s.executables = ["bro"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".rvmrc",
    "Gemfile",
    "Gemfile.lock",
    "History.txt",
    "LICENSE",
    "Manifest.txt",
    "PostInstall.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "baby-bro.gemspec",
    "bin/bro",
    "config/babybrorc.example",
    "lib/baby-bro.rb",
    "lib/baby-bro/base_config.rb",
    "lib/baby-bro/exec.rb",
    "lib/baby-bro/files.rb",
    "lib/baby-bro/hash_object.rb",
    "lib/baby-bro/monitor.rb",
    "lib/baby-bro/monitor_config.rb",
    "lib/baby-bro/project.rb",
    "lib/baby-bro/reporter.rb",
    "lib/baby-bro/session.rb",
    "lib/extensions/integer.rb",
    "script/console",
    "script/destroy",
    "script/generate",
    "spec/baby-bro_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb",
    "tasks/rspec.rake"
  ]
  s.homepage = %q{http://github.com/capitalthought/baby-bro}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{File activity monitor for time tracking.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.3.1"])
    else
      s.add_dependency(%q<rspec>, [">= 1.3.1"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.3.1"])
  end
end
