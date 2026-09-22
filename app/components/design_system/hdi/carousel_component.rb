# frozen_string_literal: true

module DesignSystem
  module Hdi
    # Horizontally scrolling row. The default variant is a generic snap
    # carousel; `:logos` renders partner/organisation marks from `items`
    # with autoplay + prev/next controls (paused for reduced motion).
    class CarouselComponent < DesignSystem::BaseComponent
      def initialize(label: nil, variant: :default, items: [])
        super()
        @label = label
        @variant = variant.to_sym
        @items = Array(items)
      end

      attr_reader :label, :variant, :items

      def logos?
        variant == :logos
      end

      def carousel_class
        classes = ['hdi-carousel']
        classes << "hdi-carousel--#{variant}"
        classes.join(' ')
      end
    end
  end
end
