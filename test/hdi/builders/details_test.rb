# frozen_string_literal: true

require 'test_helper'

module DesignSystem
  module Hdi
    module Builders
      # This tests the hdi details builder
      class DetailsTest < ActionView::TestCase
        include DesignSystemHelper

        setup do
          @brand = 'hdi'
          @controller.stubs(:brand).returns(@brand)
        end

        test 'rendering hdi details' do
          @output_buffer = ds_details('Click me to expand') do
            content_tag(:p, 'If expanded, this content will be shown.')
          end

          assert_select 'details.hdi-details' do
            assert_select 'summary.hdi-details__summary' do
              assert_select 'span.hdi-details__summary-text', text: 'Click me to expand'
            end
            assert_select 'div.hdi-details__text' do
              assert_select 'p', text: 'If expanded, this content will be shown.'
            end
          end
        end
      end
    end
  end
end
