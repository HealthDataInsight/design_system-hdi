# frozen_string_literal: true

module DesignSystem
  module Hdi
    # DaisyUI `.stats` row. Each item is title / value / description.
    class StatsComponent < DesignSystem::BaseComponent
      def initialize(items = [])
        super()
        @items = Array(items)
      end

      attr_reader :items
    end
  end
end
