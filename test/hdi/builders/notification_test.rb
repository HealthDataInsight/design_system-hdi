# frozen_string_literal: true

require 'test_helper'

module DesignSystem
  module Hdi
    module Builders
      # This tests the hdi notification builder
      class NotificationTest < ActionView::TestCase
        include DesignSystemHelper

        setup do
          @brand = 'hdi'
          @controller.stubs(:brand).returns(@brand)
        end

        # Notices are inherited unchanged from the generic builder, so they use the shared
        # notification-banner markup (header/title/content) and support the success type.
        test 'rendering hdi notice' do
          @output_buffer = ds_notice('Important Notice')

          assert_select 'div.hdi-notification-banner' do
            assert_select 'div.hdi-notification-banner__header' do
              assert_select 'h2.hdi-notification-banner__title', 'Important'
            end

            assert_select 'div.hdi-notification-banner__content', text: 'Important Notice'
          end
        end

        test 'rendering hdi notice with success type' do
          @output_buffer = ds_notice('Test content', type: :success)

          assert_select 'div.hdi-notification-banner.hdi-notification-banner--success[role="alert"]' \
                        '[aria-labelledby="hdi-notification-banner-title"][data-module="hdi-notification-banner"]' do
            assert_select 'h2.hdi-notification-banner__title', 'Success'
            assert_select 'div.hdi-notification-banner__content', text: 'Test content'
          end
        end

        test 'rendering hdi notice with a content heading' do
          @output_buffer = ds_notice('Important Notice', content_heading: { text: 'Please be aware', tag: :h3 })

          assert_select 'div.hdi-notification-banner div.hdi-notification-banner__content' do
            assert_select 'h3.hdi-notification-banner__heading', text: 'Please be aware'
          end
        end

        # Alerts stay HDI-specific (an icon-led banner rather than the generic error-summary)
        # but reuse the shared header/content banner markup.
        test 'rendering hdi alert' do
          @output_buffer = ds_alert('Test alert!')

          assert_select 'div.hdi-notification-banner.hdi-notification-banner__alert[role="alert"]' \
                        '[aria-labelledby="hdi-notification-banner-alert-title"]' do
            assert_select 'h2.hdi-notification-banner__title#hdi-notification-banner-alert-title', 'Alert'
            assert_select 'div.hdi-notification-banner__content span[data-test="alert"]', 'Test alert!'
          end
        end

        test 'rendering hdi alert with sanitisation' do
          @output_buffer = ds_alert('<p>Test alert!</p>')

          assert_select 'div.hdi-notification-banner.hdi-notification-banner__alert' do
            assert_select 'div.hdi-notification-banner__content span[data-test="alert"]', text: 'Test alert!'
          end
        end
      end
    end
  end
end
