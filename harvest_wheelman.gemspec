# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'harvest_wheelman/version'

Gem::Specification.new do |spec|
  spec.name          = "harvest_wheelman"
  spec.version       = HarvestWheelman::VERSION
  spec.authors       = ["Keyvan Fatehi"]
  spec.email         = ["keyvanfatehi@gmail.com"]
  spec.description   = %q{Logs into Harvest and generates a PDF report the way my company likes it}
  spec.summary       = %q{Logs into Harvest and generates a PDF report}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"

  spec.add_runtime_dependency 'selenium-webdriver', '>=2.31.0'
  spec.add_runtime_dependency 'timerizer'
  spec.add_runtime_dependency 'json'
end