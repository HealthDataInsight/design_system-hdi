# frozen_string_literal: true

module DesignSystem
  module Hdi
    module Builders
      # This class is used to provide HDI fixed elements builder.
      class FixedElements < ::DesignSystem::Generic::Builders::FixedElements
        include Elements::Backlink
        include Elements::Breadcrumbs
        include Elements::Headings
      end
    end
  end
end
