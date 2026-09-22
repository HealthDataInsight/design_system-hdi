# frozen_string_literal: true

module DesignSystem
  module Hdi
    # HDI breadcrumbs: home is an icon link (drawn in CSS); other crumbs get a
    # CSS chevron separator. Matches GOV.UK/NHS (icons in styles, not markup).
    #
    # Recognises +root_path+, "/" and (when defined) +website_root_path+ so the
    # marketing site can use the same home-icon treatment as the catalog.
    class BreadcrumbsComponent < DesignSystem::Generic::BreadcrumbsComponent
      def home_path?(path)
        path_str = path.to_s
        return true if path_str == helpers.root_path.to_s || path_str == '/'

        helpers.respond_to?(:website_root_path) && path_str == helpers.website_root_path.to_s
      end
    end
  end
end
