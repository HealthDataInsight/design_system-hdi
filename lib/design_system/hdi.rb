# frozen_string_literal: true

# This is the HDI branded adapter for the design system
require 'design_system'
require 'design_system/hdi/version'
require 'design_system/hdi/engine'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem_extension(DesignSystem)
loader.setup

require 'design_system/hdi/builders/button'
require 'design_system/hdi/builders/callout'
require 'design_system/hdi/builders/details'
require 'design_system/hdi/builders/fixed_elements'
require 'design_system/hdi/builders/heading'
require 'design_system/hdi/builders/link'
require 'design_system/hdi/builders/notification'
require 'design_system/hdi/builders/pagination_renderer'
require 'design_system/hdi/builders/panel'
require 'design_system/hdi/builders/summary_list'
require 'design_system/hdi/builders/tab'
require 'design_system/hdi/builders/table'

require 'design_system/hdi/form_builder'

DesignSystem::Registry.register('hdi')
