# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{baby-bro}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bill Doughty"]
  s.date = %q{2010-12-07}
  s.default_executable = %q{bro}
  s.description = %q{Baby Bro monitors the timestamps changes for files in directories on your filesystem and records time spent actively working in those directories.}
  s.email = ["billdoughty @ capitalthought . com"]
  s.executables = ["bro"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "bin/bro", "lib/baby-bro/base_config.rb", "lib/baby-bro/exec.rb", "lib/baby-bro/files.rb", "lib/baby-bro/hash_object.rb", "lib/baby-bro/monitor.rb", "lib/baby-bro/monitor_config.rb", "lib/baby-bro/project.rb", "lib/baby-bro/reporter.rb", "lib/baby-bro/session.rb", "lib/baby-bro.rb", "lib/extensions/fixnum.rb", "spec/baby-bro_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/bro.rake", "tasks/rspec.rake"]
  s.homepage = %q{http://github.com/capitalthought/baby-bro}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{baby-bro}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{File activity monitor for automatic time tracking.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_development_dependency(%q<hoe>, [">= 2.7.0"])
    else
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<hoe>, [">= 2.7.0"])
    end
  else
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<hoe>, [">= 2.7.0"])
  end
end
