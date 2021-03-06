lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'token_master/version'

Gem::Specification.new do |s|
  s.name                  = 'token_master'
  s.version               = TokenMaster::VERSION
  s.summary               = 'Token Master!'
  s.description           = 'User management using tokens'
  s.authors               = ['Dave Corwin', 'Ifat Ribon']
  s.email                 = ['dave@launchpadlab.com', 'ifat@launchpadlab.com']
  s.homepage              = 'https://github.com/launchpadlab/token-master'
  s.license               = 'MIT'
  s.required_ruby_version = '>= 2.3.0'
  s.files                 = `git ls-files -z`
                            .split("\x0")
                            .reject { |f| f.match(%r{^(test|spec|features)/}) }

  s.add_development_dependency 'rake', '~> 10.4', '>= 10.4.2'
  s.add_development_dependency 'minitest', '~> 5.10', '>= 5.10.1'
end
