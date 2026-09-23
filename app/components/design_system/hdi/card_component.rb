# frozen_string_literal: true

module DesignSystem
  module Hdi
    # DaisyUI `.card` used as a media card: image, eyebrow, result-led title
    # and supporting meta. Shared by work, news and related-work listings.
    class CardComponent < DesignSystem::BaseComponent
      def initialize(title:, **options)
        super()
        @title = title
        @eyebrow = options[:eyebrow]
        @meta = options[:meta]
        @href = options[:href]
        @image_label = options[:image_label]
        @image_src = options[:image_src]
        @image_alt = options[:image_alt]
        @tags = Array(options[:tags])
      end

      attr_reader :title, :eyebrow, :meta, :href, :image_label, :image_src, :image_alt, :tags
    end
  end
end
