# encoding: UTF-8
# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name            = 'capistrano-tweaks'
  s.version         = '1.0.0'
  s.author          = 'Yaroslav Konoplov'
  s.email           = 'eahome00@gmail.com'
  s.summary         = 'Tweaks for Capistrano 3.x'
  s.description     = 'Tweaks for Capistrano 3.x'
  s.homepage        = 'https://github.com/yivo/capistrano-tweaks'
  s.license         = 'MIT'

  s.files           = `git ls-files -z`.split("\x0")
  s.test_files      = `git ls-files -z -- {test,spec,features}/*`.split("\x0")
  s.require_paths   = ['lib']

  s.add_dependency 'capistrano', '~> 3.1'
end
