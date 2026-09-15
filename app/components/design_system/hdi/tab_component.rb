# frozen_string_literal: true

module DesignSystem
  module Hdi
    # HDI tabs use button + Stimulus controls rather than the generic
    # anchor/data-module tabs, so they ship their own template.
    class TabComponent < DesignSystem::Generic::TabComponent
    end
  end
end
