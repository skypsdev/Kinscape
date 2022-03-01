$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'encrypted_action_text/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'encrypted_action_text'
  spec.version     = EncryptedActionText::VERSION
  spec.authors     = ['Mauricio Zaffari']
  spec.email       = ['mauriciozaffari@gmail.com']
  spec.summary     = 'Allows encrypted action text content'
  spec.description = 'Extends action text rich texts so they can be encrypted'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE',
                   'Rakefile', 'README.md']

  spec.add_dependency 'rails', '~> 6.1.0'

  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'rspec'
end
