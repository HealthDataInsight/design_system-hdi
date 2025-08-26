# DesignSystem::Hdi

DesignSystem is an extensible Ruby on Rails engine that enables consistent, compliant web applications across design systems.

The gem is a plugin for the Health Data Insight (HDI) design system.

## Usage

How to use the plugin.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'design_system-hdi'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install design_system-hdi
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

## Contributing

Contribution directions go here.

Created using:

```bash
rails _7.1.5.2_ plugin new design_system -MOC --skip-system-test --full --no-mountable
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
