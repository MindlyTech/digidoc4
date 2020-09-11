require_relative 'lib/digidoc4/version'

Gem::Specification.new do |spec|
  spec.name          = 'digidoc4'
  spec.version       = Digidoc4::VERSION
  spec.author        = %w[Mindly]
  spec.homepage      = 'https://git.mindly.dev/plusplus/digidoc4'

  spec.summary       = 'This makes it easier to communicate with SmartID and MobileID API.'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://git.mindly.dev/plusplus/digidoc4'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'httparty'

  spec.add_development_dependency 'rspec'
end
