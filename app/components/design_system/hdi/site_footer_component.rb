# frozen_string_literal: true

module DesignSystem
  module Hdi
    # Design-system site footer — same chrome as layouts/hdi/application:
    # .hdi-footer-container / .hdi-footer link list + copyright.
    # End-of-page CTAs belong in CtaBandComponent (inside <main>), not here.
    class SiteFooterComponent < DesignSystem::BaseComponent
      def initialize(links: nil, copyright: nil)
        super()
        @links = links
        @copyright = copyright
      end

      def links
        return Array(@links) unless @links.nil?

        controller = helpers.controller
        return [] unless controller.respond_to?(:footer_links)

        Array(controller.footer_links)
      end

      def copyright
        return @copyright unless @copyright.nil?

        controller = helpers.controller
        return nil unless controller.respond_to?(:copyright_notice)

        controller.copyright_notice
      end

      def link_hash(link)
        link.respond_to?(:symbolize_keys) ? link.symbolize_keys : link
      end
    end
  end
end
