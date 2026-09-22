# frozen_string_literal: true

module DesignSystem
  module Hdi
    # Marketing hero. Default is a two-column layout (copy + media slot).
    # Pass +background_image+ for a full-bleed image hero with no media column.
    class HeroComponent < DesignSystem::BaseComponent
      def initialize(title:, lede: nil, primary: nil, secondary: nil, media_label: nil,
                     background_image: nil)
        super()
        @title = title
        @lede = lede
        @primary = primary&.symbolize_keys
        @secondary = secondary&.symbolize_keys
        @media_label = media_label
        @background_image = background_image
      end

      attr_reader :title, :lede, :primary, :secondary, :media_label, :background_image

      def image_hero?
        background_image.present?
      end

      def hero_classes
        classes = ['hdi-section', 'hdi-hero']
        classes << 'hdi-hero--image' if image_hero?
        classes.join(' ')
      end

      def hero_style
        return unless image_hero?

        "--hdi-hero-image: url(#{background_image});"
      end
    end
  end
end
