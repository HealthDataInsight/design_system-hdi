require_relative 'lib/design_system/hdi/version'

Gem::Specification.new do |spec|
  spec.name        = 'design_system-hdi'
  spec.version     = DesignSystem::Hdi::VERSION
  spec.authors     = ['Filis Liu', 'Nick Robinson', 'Shilpi Goel', 'Tim Gentry']
  spec.email       = ['52189+timgentry@users.noreply.github.com']
  spec.homepage    = 'https://github.com/HealthDataInsight/design_system-hdi'
  spec.summary     = 'Design System plugin for Health Data Insight (HDI)'
  spec.license     = 'MIT'
  spec.required_ruby_version = '>= 3.1.6'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/HealthDataInsight/design_system-hdi'
  spec.metadata['changelog_uri'] = 'https://github.com/HealthDataInsight/design_system-hdi/CHANGELOG.md'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib,public}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'design_system', '~> 0.7.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
