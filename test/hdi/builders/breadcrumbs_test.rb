require 'test_helper'

module DesignSystem
  module Hdi
    module Builders
      # This tests the HDI breadcrumbs builder
      class BreadcrumbsTest < ActionView::TestCase
        include DesignSystemHelper

        setup do
          @controller.stubs(:brand).returns('hdi')
        end

        test 'rendering HDI breadcrumbs' do
          ds_fixed_elements do |ds|
            ds.breadcrumb('Home', root_path)
            ds.breadcrumb('Somewhere else', rails_health_check_path)
          end

          # Breadcrumbs are rendered with content_for(:breadcrumbs),
          # so to test the generated HTML, we need to copy it to the
          # output buffer.
          @output_buffer = @view_flow.get(:breadcrumbs)

          assert_select('nav', 'aria-label': 'Breadcrumb') do
            assert_select('ol[role=list]') do
              # Home icon is drawn via CSS (.hdi-breadcrumbs__link--home::before),
              # not inline markup — same pattern as .hdi-back-link.
              assert_select('li.hdi-breadcrumbs__item:nth-child(1)') do
                assert_select('div.hdi-breadcrumbs__link-wrapper--home') do
                  assert_select('a.hdi-breadcrumbs__link--home', href: root_url) do
                    assert_select('span.sr-only', text: 'Home')
                    assert_select('svg', false)
                  end
                end
              end

              # Divider chevron is drawn via CSS (.hdi-breadcrumbs__link-wrapper::before).
              assert_select('li.hdi-breadcrumbs__item:nth-child(2)') do
                assert_select('div.hdi-breadcrumbs__link-wrapper') do
                  assert_select('a.hdi-breadcrumbs__link', href: rails_health_check_path, text: 'Somewhere else')
                  assert_select('svg', false)
                end
              end
            end
          end
        end
      end
    end
  end
end
