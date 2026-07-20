module DesignSystem
  module Hdi
    module Builders
      module Elements
        # Backlink should not coexist with breadcrumbs.
        module Backlink
          include ::DesignSystem::Generic::Builders::Elements::Backlink

          # rubocop:disable Rails/OutputSafety
          BACKLINK_LEFT_CHEVRON_SVG = <<~SVG.html_safe
            <svg class="hdi-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="12 0 12 24">
              <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5 8.25 12l7.5-7.5" />
            </svg>
          SVG
          # rubocop:enable Rails/OutputSafety

          private

          def render_backlink
            link_to(@path, class: "#{brand}-back-link") do
              BACKLINK_LEFT_CHEVRON_SVG + @label.to_s
            end
          end
        end
      end
    end
  end
end
