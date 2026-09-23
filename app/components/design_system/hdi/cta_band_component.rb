# frozen_string_literal: true

module DesignSystem
  module Hdi
    # Closing CTA as an in-page panel (wireframe P11): contained indigo card
    # with rounded corners inside the content measure — not a full-bleed band
    # and not footer chrome. Title + lede on the left, action on the right.
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
        classes = %w[hdi-section hdi-cta-band]
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
