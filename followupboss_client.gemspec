lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fub_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'followupboss_client'
  spec.version       = FubClient::VERSION
  spec.authors       = ['Connor Gallopo', 'Kyoto Kopz']
  spec.email         = ['connor.gallopo@me.com']

  spec.summary       = 'Enhanced Ruby client for Follow Up Boss API with Rails 8 compatibility'
  spec.description   = 'A comprehensive Ruby client for the Follow Up Boss API with Rails 8 compatibility, secure cookie authentication for SharedInbox, and enhanced features for real estate CRM integration.'
  spec.homepage      = 'https://github.com/connorgallopo/followupboss_client'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.' unless spec.respond_to?(:metadata)

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) || f.match(%r{\.gem$}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel', '>= 7.1.0', '< 9.0'
  spec.add_dependency 'activesupport', '>= 7.1.0', '< 9.0'
  spec.add_dependency 'facets', '~> 3.1.0'
  spec.add_dependency 'faraday', '>= 1.10.3', '< 3.0'
  spec.add_dependency 'her', '~> 1.1.1'
  spec.add_dependency 'logger'
  spec.add_dependency 'multi_json', '~> 1.15.0'
  spec.add_dependency 'tzinfo', '~> 2.0.6'
  # Development
  spec.add_development_dependency 'bundler', '~> 2.4'
  spec.add_development_dependency 'dotenv', '>= 2.8.1'
  spec.add_development_dependency 'pry', '>= 0.14.2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'vcr', '>= 6.1.0'
  spec.add_development_dependency 'webmock', '>= 3.18.1'
end
