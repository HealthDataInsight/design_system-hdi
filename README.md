# DesignSystem::Hdi

DesignSystem is an extensible Ruby on Rails engine that enables consistent, compliant web applications across design systems.

The gem is a plugin for the Health Data Insight (HDI) design system.

## Usage

How to use the plugin.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

Add the following to `app/javascript/controllers/index.js`, after `import { application } from './application'`:

```javascript
import { registerControllers } from 'design_system/controllers'
registerControllers(application)
```

Add the following to `app/controllers/application_controller.rb`:

```ruby
class ApplicationController < ActionController::Base
  include DesignSystem::Branded

  helper HdiHelper

  # ...
end
```

## Updating HDI Frontend

Updating the HDI Frontend is currently a manual process.

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/HealthDataInsight/design_system-hdi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/HealthDataInsight/design_system-hdi/blob/main/CODE_OF_CONDUCT.md).

Created using:

```bash
rails _7.1.5.2_ plugin new design_system -MOC --skip-system-test --full --no-mountable
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DesignSystem::Hdi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/HealthDataInsight/design_system-hdi/blob/main/CODE_OF_CONDUCT.md).
