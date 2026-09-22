# frozen_string_literal: true

require 'test_helper'

module DesignSystem
  module Hdi
    module Components
      class ServiceSpineTest < ActionView::TestCase
        include DesignSystemHelper
        include HdiHelper

        setup do
          @brand = 'hdi'
          @controller.stubs(:brand).returns(@brand)
        end

        test 'renders interactive steps and a single active indigo panel' do
          @output_buffer = ds_service_spine([
                                               { spine: 'TRANSFORM', name: 'Strategy & Transformation',
                                                 summary: 'Work out what to change.',
                                                 offerings: ['Health data strategy', 'Discovery'],
                                                 href: '/services/strategy', content: '1', current: true },
                                               { spine: 'CONNECT', name: 'Data & Analytics',
                                                 summary: 'Trusted evidence.',
                                                 offerings: ['Linkage'],
                                                 href: '/services/data', content: '2' }
                                             ])

          assert_select '.hdi-service-spine[data-controller="service-spine"]' do
            assert_select 'ul.hdi-service-spine__steps[role="radiogroup"]' do
              assert_select 'input.hdi-steps__input[type="radio"]', count: 2
              assert_select 'input.hdi-steps__input[checked]', count: 1
              assert_select 'input.hdi-steps__input[checked][value="0"]'
              assert_select '.hdi-steps__name', text: 'TRANSFORM'
              assert_select '.hdi-steps__caption', text: 'Strategy & Transformation'
            end

            assert_select '.hdi-service-spine__panel', count: 2
            assert_select '.hdi-service-spine__panel.is-active', count: 1
            assert_select '.hdi-service-spine__panel.is-active .hdi-service-spine__title',
                          text: 'Strategy & Transformation'
            assert_select '.hdi-service-spine__panel.is-active .hdi-service-spine__offerings li', count: 2
            assert_select '.hdi-service-spine__panel[hidden]', count: 1
            assert_select '.hdi-service-spine__panel.is-active .hdi-media-placeholder'
            assert_select '.hdi-service-spine__panel.is-active a', text: 'Explore'
          end
        end

        test 'defaults the first item when none are marked current' do
          @output_buffer = ds_service_spine([
                                               { spine: 'BUILD', name: 'Technology', summary: 'Build it.', href: '#' },
                                               { spine: 'DELIVER', name: 'Delivery', summary: 'Land it.', href: '#' }
                                             ])

          assert_select 'input.hdi-steps__input[checked][value="0"]'
          assert_select '.hdi-service-spine__panel.is-active .hdi-service-spine__title', text: 'Technology'
        end
      end
    end
  end
end
