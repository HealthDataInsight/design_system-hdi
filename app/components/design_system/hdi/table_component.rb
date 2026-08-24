# frozen_string_literal: true

module DesignSystem
  module Hdi
    # HDI responsive table. Shares cell helpers with the generic component but
    # uses its own container/responsive markup (see sidecar template).
    class TableComponent < DesignSystem::Generic::TableComponent
      def container_options
        css_class_options_merge(options.dup, ["#{brand}-table-container"])
      end
    end
  end
end
