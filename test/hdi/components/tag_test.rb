# frozen_string_literal: true

require 'test_helper'

module DesignSystem
  module Hdi
    module Components
      class TagTest < ActionView::TestCase
        include DesignSystemHelper
        include HdiHelper

        setup do
          @brand = 'hdi'
          @controller.stubs(:brand).returns(@brand)
        end

        test 'service tags are outline badges' do
          @output_buffer = ds_tag('Data & Analytics', '/website/our-work?service=data-and-analytics', facet: :service)

          assert_select 'a.badge.badge-outline[href="/website/our-work?service=data-and-analytics"]',
                        text: 'Data & Analytics'
        end

        test 'keyword tags are soft badges' do
          @output_buffer = ds_tag('Synthetic data', '/website/our-work?keyword=synthetic-data', facet: :method)

          assert_select 'a.badge.badge-soft', text: 'Synthetic data'
        end

        test 'active tags use the filled is-active treatment' do
          @output_buffer = ds_tag('All', '/website/our-work', facet: :subject, active: true)

          assert_select 'a.badge.is-active[aria-current="page"][href="/website/our-work"]', text: 'All'
          assert_select 'a.badge.badge-soft', count: 0
        end
      end
    end
  end
end
