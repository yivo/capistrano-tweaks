# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-tweaks'
  spec.version       = '1.0.0'
  spec.authors       = ['Yaroslav Konoplov']
  spec.email         = ['yaroslav@inbox.com']
  spec.summary       = 'Tweaks for Capistrano 3.x'
  spec.description   = 'Tweaks for Capistrano 3.x'
  spec.homepage      = 'https://github.com/yivo/capistrano-mysql'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'capistrano', '~> 3.1'
  spec.add_dependency 'sshkit', '~> 1.2'
  spec.add_dependency 'confo-config'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
