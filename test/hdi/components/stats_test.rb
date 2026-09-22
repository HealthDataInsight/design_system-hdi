# frozen_string_literal: true

require 'test_helper'

module DesignSystem
  module Hdi
    module Components
      class StatsTest < ActionView::TestCase
        include DesignSystemHelper
        include HdiHelper
        # So ViewComponent `helpers.hdi_icon` resolves (controller helpers, not only the view).
        helper HdiHelper

        setup do
          @brand = 'hdi'
          @controller.stubs(:brand).returns(@brand)
        end

        test 'rendering stats' do
          @output_buffer = ds_stats([
                                      { title: 'Working since 2011', value: '15 years', description: 'with national health data' }
                                    ])

          assert_select '.stats.hdi-stats' do
            assert_select '.stat-title', text: 'Working since 2011'
            assert_select '.stat-value', text: '15 years'
            assert_select '.stat-desc', text: 'with national health data'
            assert_select '.stat-figure', count: 0
          end
        end

        test 'rendering stats with optional icons' do
          @output_buffer = ds_stats([
                                      { title: 'In the team', value: '25', description: 'analysts and engineers', icon: 'users' }
                                    ])

          assert_select '.stats.hdi-stats .stat' do
            assert_select '.stat-figure img.hdi-icon[src="/design_system/static/heroicons-2.1.5/icon-users.svg"]'
            assert_select '.stat-value', text: '25'
          end
        end
      end
    end
  end
end
