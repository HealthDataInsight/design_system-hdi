# frozen_string_literal: true

require 'test_helper'

module DesignSystem
  module Hdi
    module Components
      class PartnerGridTest < ActionView::TestCase
        include DesignSystemHelper
        include HdiHelper

        setup do
          @brand = 'hdi'
          @controller.stubs(:brand).returns(@brand)
        end

        test 'featured logos sit above unlabeled carousel rows' do
          @output_buffer = ds_partner_grid(
            heading: 'Who we work with',
            featured: [{ name: 'NHS England', src: '/website/partners/NHS-E-logo.png' }],
            groups: [
              { label: 'Charities', name: 'Charities', logos: [{ name: 'brainstrust' }] }
            ]
          )

          assert_select '.hdi-partner-featured .hdi-logo--featured img[src="/website/partners/NHS-E-logo.png"]'
          assert_select '.hdi-section__inner .hdi-partner-grid__rows .hdi-partner-row .hdi-carousel--logos[aria-label="Charities"]'
          assert_select '.hdi-partner-row h3', count: 0
          assert_select 'h3', text: 'Charities', count: 0
          # Rows must stay inside the content container (not viewport-bleed).
          assert_select '.hdi-partner-grid > .hdi-partner-grid__rows', count: 0
        end

        test 'service-scoped grid renders tags without featured chrome' do
          @output_buffer = ds_partner_grid(
            heading: 'Who we work with on this',
            tags: ['Academic researchers', 'NHS clinicians'],
            groups: [{ logos: [{ name: 'brainstrust', src: '/website/partners/brainstrust-logo.jpg' }] }]
          )

          assert_select 'h2', text: 'Who we work with on this'
          assert_select '.hdi-chip-row .badge', count: 2
          assert_select '.hdi-chip-row .badge', text: 'Academic researchers'
          assert_select '.hdi-partner-featured', count: 0
          assert_select '.hdi-partner-row .hdi-carousel--logos img', count: 1
          assert_select 'p', count: 0
        end
      end
    end
  end
end
