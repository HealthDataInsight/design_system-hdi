# frozen_string_literal: true

module DesignSystem
  module Hdi
    # DaisyUI badge used as a filterable tag. `:service` is outline; every
    # other facet (subject, method, output) is soft. Always a link when href
    # is present, so a tag can land on the filtered listing. Active chips
    # use a filled primary treatment so the current filter is obvious.
    class TagComponent < DesignSystem::BaseComponent
      def initialize(label, href = nil, facet: :keyword, active: false)
        super()
        @label = label
        @href = href
        @facet = facet.to_sym
        @active = active
      end

      attr_reader :label, :href, :facet

      def active?
        @active
      end

      def badge_class
        classes = ['badge']
        if active?
          classes << 'is-active'
        else
          classes << (facet == :service ? 'badge-outline' : 'badge-soft')
        end
        classes.join(' ')
      end
    end
  end
end
