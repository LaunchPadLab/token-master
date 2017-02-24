lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lp_token_master/version'

Gem::Specification.new do |s|
  s.name        = 'lp_token_master'
  s.version     = LpTokenMaster::VERSION
  s.date        = '2017-02-24'
  s.summary     = 'Token Master!'
  s.description = 'User management using tokens'
  s.authors     = ['Dave Corwin', 'Ifat Ribon']
  s.email       = 'dave@launchpadlab.com'
  s.homepage    = 'https://github.com/launchpadlab/lp_token_master'
  s.license     = 'MIT'
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
end
