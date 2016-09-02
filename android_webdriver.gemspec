# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'android_webdriver/version'

Gem::Specification.new do |spec|
  spec.name          = "android_webdriver"
  spec.version       = AndroidWebDriver::VERSION
  spec.authors       = ["新川 盛幸"]
  spec.email         = ["fire_extinguisher-@ezweb.ne.jp"]

  spec.summary       = %q{android webdriver}
  spec.description   = %q{android webdriver}
  spec.homepage      = "https://github.com/arakawamoriyuki"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = ['android_webdriver']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_dependency 'appium_lib'
  spec.add_dependency 'selenium-webdriver'
  spec.add_dependency 'thor'
  spec.add_dependency 'parallel'
end
