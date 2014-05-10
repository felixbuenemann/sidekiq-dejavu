# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/dejavu/version'

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-dejavu"
  spec.version       = Sidekiq::Dejavu::VERSION
  spec.authors       = ["Felix Buenemann"]
  spec.email         = ["buenemann@louis.info"]
  spec.summary       = %q{Dejavu is a clockless scheduler that uses Sidekiq's built-in scheduling}
  spec.description   = %q{Dejavu uses Sidkiq's internal scheduling so it doesn't need its own clock and integrates nicely with Sidekiq's native scheduled jobs.}
  spec.homepage      = "https://github.com/felixbuenemann/sidekiq-dejavu"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sidekiq", "~> 3.0"
  spec.add_dependency "parse-cron", "~> 0.1.4"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
