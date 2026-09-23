# frozen_string_literal: true

module DesignSystem
  module Hdi
    # Heading, optional link and a row of media cards. `tone` tints the
    # surrounding section; `items` are hashes passed through to CardComponent.
    class CardGridComponent < DesignSystem::BaseComponent
      def initialize(heading: nil, link_label: nil, link_href: nil, tone: :default, items: [])
        super()
        @heading = heading
        @link_label = link_label
        @link_href = link_href
        @tone = tone.to_sym
        @items = Array(items)
      end

      attr_reader :heading, :link_label, :link_href, :tone, :items

      def section_class
        classes = %w[hdi-section hdi-card-grid]
        classes << 'hdi-section--tint' if tone == :light
        # :dark = indigo cards only (no full-bleed purple section).
        classes << "hdi-card-grid--#{tone}"
        classes.join(' ')
      end
    end
  end
end
