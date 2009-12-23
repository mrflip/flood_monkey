# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rack-flash}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pat Nakajima"]
  s.date = %q{2009-02-26}
  s.email = %q{patnakajima@gmail.com}
  s.files = [
    "lib/rack-flash.rb",
    "lib/rack/flash.rb",
    "lib/rack/flash/test.rb"
  ]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Flash hash implementation for Rack apps.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 0"])
    else
      s.add_dependency(%q<rack>, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 0"])
  end
end
