# frozen_string_literal: true

module DesignSystem
  module Hdi
    # Public-site top navigation: brand, primary links with optional dropdowns,
    # optional search, and a persistent call-to-action.
    class NavbarComponent < DesignSystem::BaseComponent
      def initialize(items: [], cta: nil, home_href: '/', search_href: nil)
        super()
        @items = Array(items)
        @cta = cta&.symbolize_keys
        @home_href = home_href
        @search_href = search_href
      end

      attr_reader :items, :cta, :home_href, :search_href

      def search?
        search_href.present?
      end

      def item_hash(item)
        item.respond_to?(:symbolize_keys) ? item.symbolize_keys : item
      end

      def link_class(href)
        classes = ['hdi-navbar__link']
        classes << 'is-active' if href.present? && helpers.current_page?(href)
        classes.join(' ')
      end
    end
  end
end
