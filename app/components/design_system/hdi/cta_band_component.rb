# frozen_string_literal: true

module DesignSystem
  module Hdi
    # End-of-page call-to-action band. Lives in page content (inside <main>),
    # not in the site footer — title, lede, and one or two actions on a
    # contrasting indigo strip with a purple border above the real DS footer.

    class CtaBandComponent < DesignSystem::BaseComponent
      TONES = %i[contrast].freeze

      def initialize(title:, lede: nil, primary: nil, secondary: nil, tone: :contrast)
        super()
        @title = title
        @lede = lede
        @primary = primary&.symbolize_keys
        @secondary = secondary&.symbolize_keys
        @tone = tone.to_sym
        @tone = :contrast unless TONES.include?(@tone)
      end

      attr_reader :title, :lede, :primary, :secondary, :tone

      def section_class
        classes = %w[hdi-cta-band]
        classes << "hdi-cta-band--#{tone}"
        classes.join(' ')
      end

      def primary_type
        primary[:type] || default_primary_type
      end

      def secondary_type
        secondary[:type] || :secondary_button
      end

      private

      def default_primary_type
        tone == :contrast ? :reverse_button : :button
      end
    end
  end
end
