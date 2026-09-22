# frozen_string_literal: true

require 'test_helper'

module DesignSystem
  module Hdi
    module Components
      class CardTest < ActionView::TestCase
        include DesignSystemHelper
        include HdiHelper

        setup do
          @brand = 'hdi'
          @controller.stubs(:brand).returns(@brand)
        end

        test 'rendering a media card' do
          @output_buffer = ds_card(
            title: 'Synthetic cancer data',
            eyebrow: 'Data & Analytics',
            meta: 'Simulacrum v2',
            href: '/website/our-work/simulacrum-v2',
            image_label: 'Synthetic data'
          )

          assert_select 'article.card.hdi-media-card' do
            assert_select '.hdi-media-placeholder', text: 'Synthetic data'
            assert_select '.hdi-media-card__eyebrow', text: 'Data & Analytics'
            assert_select 'h3.card-title a[href="/website/our-work/simulacrum-v2"]', text: 'Synthetic cancer data'
            assert_select '.hdi-media-card__meta', text: 'Simulacrum v2'
          end
        end
      end
    end
  end
end
