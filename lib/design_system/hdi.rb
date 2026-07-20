# frozen_string_literal: true

# This is the HDI branded adapter for the design system
require 'design_system'
require 'design_system/hdi/version'
require 'design_system/hdi/engine'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem_extension(DesignSystem)
loader.setup

DesignSystem::Registry.register('hdi')
