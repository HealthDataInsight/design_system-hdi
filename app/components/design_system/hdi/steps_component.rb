# frozen_string_literal: true

module DesignSystem
  module Hdi
    # DaisyUI `.steps`.
    # `progress: :through` (default) marks every step up to and including `current`
    # as primary — for sequential timelines and methodologies.
    # `progress: :current` marks only the `current` step — for non-sequential peers
    # (e.g. overlapping services).
    # `interactive: true` makes steps selectable; captions disclose only for the
    # selected step (progressive disclosure). Highlighting follows the selection
    # via CSS rather than sequential `step-primary` progress.
    # `orientation: :vertical` is used for timelines.
    class StepsComponent < DesignSystem::BaseComponent
      PROGRESS_MODES = %i[through current].freeze

      def initialize(items = [], orientation: :horizontal, progress: :through, interactive: false)
        super()
        @items = Array(items)
        @orientation = orientation.to_sym
        @progress = progress.to_sym
        @interactive = interactive
        raise ArgumentError, "Unknown progress: #{@progress}" unless PROGRESS_MODES.include?(@progress)
      end

      attr_reader :items, :orientation, :progress

      def interactive?
        @interactive
      end

      def steps_class
        classes = %w[steps hdi-steps]
        classes << 'steps-vertical' if orientation == :vertical
        classes << 'hdi-steps--current' if progress == :current && !interactive?
        classes << 'hdi-steps--interactive' if interactive?
        classes.join(' ')
      end

      def group_name
        @group_name ||= "hdi-steps-#{object_id}"
      end

      def current_index
        index = items.index { |item| truthy?(item_hash(item)[:current]) }
        index || -1
      end

      def step_class(index)
        classes = ['step']
        classes << 'step-primary' if primary_step?(index)
        classes.join(' ')
      end

      def item_hash(item)
        item.respond_to?(:symbolize_keys) ? item.symbolize_keys : item
      end

      def input_id(index)
        "#{group_name}-#{index}"
      end

      def selected?(item)
        truthy?(item_hash(item)[:current])
      end

      private

      def primary_step?(index)
        return false if interactive?
        return false if current_index.negative?

        case progress
        when :through then index <= current_index
        when :current then index == current_index
        end
      end

      def truthy?(value)
        value == true || value.to_s == 'true'
      end
    end
  end
end
