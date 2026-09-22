# frozen_string_literal: true

module DesignSystem
  module Hdi
    # Decorative stand-in for photography or a short loop. Used by the media
    # card, hero, and any other block that needs a reserved image slot.
    class MediaPlaceholderComponent < DesignSystem::BaseComponent
      def initialize(label: nil, variant: :default)
        super()
        @label = label
        @variant = variant
      end

      attr_reader :label, :variant

      def call
        content_tag(:div, label.presence || 'Image', class: placeholder_class, 'aria-hidden': 'true')
      end

      private

      def placeholder_class
        classes = ['hdi-media-placeholder']
        classes << 'hdi-media-placeholder--portrait' if variant.to_sym == :portrait
        classes.join(' ')
      end
    end
  end
end
