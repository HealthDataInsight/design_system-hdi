# frozen_string_literal: true

require 'test_helper'

module DesignSystem
  module Hdi
    module Components
      class SiteFooterTest < ActionView::TestCase
        include DesignSystemHelper
        include HdiHelper

        setup do
          @brand = 'hdi'
          @controller.stubs(:brand).returns(@brand)
        end

        test 'renders the established HDI footer chrome' do
          @output_buffer = ds_site_footer(
            links: [
              { name: 'About', href: '/website/about' },
              { name: 'Talk to us', href: '/website/contact', options: { target: '_blank' } }
            ],
            copyright: 'Copyright © 2025 Health Data Insight CIC'
          )

          assert_select 'footer[role=contentinfo] .hdi-footer-container .hdi-footer' do
            assert_select 'ul.hdi-footer__list li.hdi-footer__list-item a.hdi-footer__list-item-link[href="/website/about"]',
                          text: 'About'
            assert_select 'a.hdi-footer__list-item-link[href="/website/contact"][target=_blank]',
                          text: 'Talk to us'
            assert_select 'p.hdi-footer__copyright', text: 'Copyright © 2025 Health Data Insight CIC'
          end
          assert_select '.hdi-site-footer', count: 0
        end
      end
    end
  end
end
