# frozen_string_literal: true

require 'test_helper'

module DesignSystem
  module Hdi
    module Components
      class CtaBandTest < ActionView::TestCase
        include DesignSystemHelper
        include HdiHelper

        setup do
          @brand = 'hdi'
          @controller.stubs(:brand).returns(@brand)
        end

        test 'rendering a contrast CTA band' do
          @output_buffer = ds_cta_band(
            title: 'Tell us your challenge',
            lede: 'A paragraph about the problem is enough to start.',
            primary: { label: 'Start a conversation', href: '/website/contact' }
          )

          assert_select 'section.hdi-cta-band.hdi-cta-band--contrast' do
            assert_select 'h2', text: 'Tell us your challenge'
            assert_select 'p', text: 'A paragraph about the problem is enough to start.'
            assert_select 'a.hdi-button.hdi-button--reverse[href="/website/contact"]',
                          text: 'Start a conversation'
          end
        end

        test 'optional secondary action' do
          @output_buffer = ds_cta_band(
            title: 'Working on something similar?',
            primary: { label: 'Start a conversation', href: '/contact' },
            secondary: { label: 'See our work', href: '/work' }
          )

          assert_select '.hdi-button-row' do
            assert_select 'a[href="/contact"]', text: 'Start a conversation'
            assert_select 'a[href="/work"]', text: 'See our work'
          end
        end
      end
    end
  end
end
