# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_flag/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_flag'
  spec.version       = ActiveFlag::VERSION
  spec.authors       = ['Kenn Ejima']
  spec.email         = ['kenn.ejima@gmail.com']

  spec.summary       = %q{Bit array for ActiveRecord}
  spec.description   = %q{Bit array for ActiveRecord}
  spec.homepage      = 'https://github.com/kenn/active_flag'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activerecord', '>= 5'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'sqlite3'
end
