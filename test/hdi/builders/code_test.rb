# frozen_string_literal: true

require 'test_helper'

module DesignSystem
  module Hdi
    module Builders
      # This tests the hdi code builder
      class CodeTest < ActionView::TestCase
        include DesignSystemHelper
        include HdiHelper

        setup do
          @brand = 'hdi'
          @controller.stubs(:brand).returns(@brand)
        end

        test 'rendering hdi code block' do
          @output_buffer = ds_code('puts "hello"', 'ruby')

          assert_select 'div.hdi-code-container' do
            assert_select 'div.hdi-code-heading' do
              assert_select 'span', text: 'Ruby'
              assert_select 'button.hdi-clipboard-button' do
                assert_select 'img.hdi-clipboard-button__icon'
                assert_select 'span.hdi-clipboard-button__label', text: 'Copy'
              end
            end
            assert_select 'pre.hdi-code-console code.hljs.language-ruby', text: 'puts "hello"'
          end
        end
      end
    end
  end
end
