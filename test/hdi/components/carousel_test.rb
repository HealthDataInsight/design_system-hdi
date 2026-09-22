# frozen_string_literal: true

require 'test_helper'

module DesignSystem
  module Hdi
    module Components
      class CarouselTest < ActionView::TestCase
        include DesignSystemHelper
        include HdiHelper

        setup do
          @brand = 'hdi'
          @controller.stubs(:brand).returns(@brand)
        end

        test 'rendering a logo carousel' do
          @output_buffer = ds_carousel(
            label: 'NHS partners',
            variant: :logos,
            items: [{ name: 'NHS England' }, { name: 'NDRS' }]
          )

          assert_select '.hdi-carousel.hdi-carousel--logos[aria-label="NHS partners"][data-controller="carousel"]' do
            assert_select 'button.hdi-carousel__control--prev[aria-label="Previous nhs partners"]', count: 1
            assert_select 'button.hdi-carousel__control--next[aria-label="Next nhs partners"]', count: 1
            assert_select '.hdi-carousel__track[data-carousel-target="track"]' do
              assert_select '.hdi-logo-mark', count: 2
              assert_select '.hdi-logo-mark', text: 'NHS England'
            end
          end
        end

        test 'rendering a logo carousel with images' do
          @output_buffer = ds_carousel(
            label: 'NHS partners',
            variant: :logos,
            items: [{ name: 'NHS England', src: '/website/partners/NHS-E-logo.png', alt: 'NHS England' }]
          )

          assert_select '.hdi-carousel--logos .hdi-carousel__track .hdi-logo img[src="/website/partners/NHS-E-logo.png"][alt="NHS England"]'
        end
      end
    end
  end
end
