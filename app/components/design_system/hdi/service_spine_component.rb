# frozen_string_literal: true

module DesignSystem
  module Hdi
    # Interactive “What we do” spine: numbered step markers with one full-width
    # indigo panel showing the selected service. Distinct from StepsComponent’s
    # methodology mode (`interactive: true`), which discloses captions inline.
    #
    # Each item: spine, name, summary, offerings, href, media_label (optional).
    # The first item is selected by default unless one sets `current: true`.
    class ServiceSpineComponent < DesignSystem::BaseComponent
      def initialize(items = [], interval: 5_000, label: 'What we do')
        super()
        @items = Array(items)
        @interval = interval.to_i
        @label = label
      end

      attr_reader :items, :interval, :label

      def group_name
        @group_name ||= "hdi-service-spine-#{object_id}"
      end

      def current_index
        index = items.index { |item| truthy?(item_hash(item)[:current]) }
        index || 0
      end

      def item_hash(item)
        item.respond_to?(:symbolize_keys) ? item.symbolize_keys : item
      end

      def input_id(index)
        "#{group_name}-#{index}"
      end

      def panel_id(index)
        "#{group_name}-panel-#{index}"
      end

      def selected?(index)
        index == current_index
      end

      private

      def truthy?(value)
        value == true || value.to_s == 'true'
      end
    end
  end
end
