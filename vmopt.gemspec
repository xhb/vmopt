# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vmopt/version'

Gem::Specification.new do |spec|
  spec.name          = "vmopt"
  spec.version       = Vmopt::VERSION
  spec.authors       = ["xhb"]
  spec.email         = ["programstart@163.com"]
  spec.description   = %q{
                          Internal virtual machine operations application： 
                          including Notepad operations, 
                          disk management, 
                          connectivity testing, 
                          drive management, 
                          system resource queries, 
                          network test, serial test, 
                          windows system power management
                        }
  spec.summary       = %q{Internal virtual machine operations application}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
