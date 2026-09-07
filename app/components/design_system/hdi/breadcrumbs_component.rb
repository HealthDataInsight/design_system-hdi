# frozen_string_literal: true

module DesignSystem
  module Hdi
    # HDI breadcrumbs: home is an icon link (drawn in CSS); other crumbs get a
    # CSS chevron separator. Matches GOV.UK/NHS (icons in styles, not markup).
    class BreadcrumbsComponent < DesignSystem::Generic::BreadcrumbsComponent
      def home_path?(path)
        path.to_s == helpers.root_path || path.to_s == '/'
      end
    end
  end
end
