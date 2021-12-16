# frozen_string_literal: true

require_relative "lib/cloudmunda/version"

Gem::Specification.new do |spec|
  spec.name = "cloudmunda"
  spec.version = Cloudmunda::VERSION
  spec.authors = ["Lien Van Den Steen"]
  spec.email = ["lienvandensteen@gmail.com"]

  spec.summary = "Ruby wrapper for Camunda Cloud"
  spec.description = "Ruby wrapper for Camunda Cloud"
  spec.homepage = "https://github.com/lienvdsteen/cloudmunda"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/lienvdsteen/cloudmunda"
  spec.metadata["changelog_uri"] = "https://github.com/lienvdsteen/cloudmunda"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'rest-client', '~> 2.0'
  spec.add_dependency "zeebe-client", "~> 0.16"
  spec.add_dependency "concurrent-ruby", "~> 1.0"
end
