# frozen_string_literal: true

module DesignSystem
  module Hdi
    # HDI button: uses `--reverse` (not `--inverse`) and adds a `--disabled`
    # modifier class alongside the native disabled attribute.
    class ButtonComponent < DesignSystem::Nhsuk::ButtonComponent
    end
  end
end
