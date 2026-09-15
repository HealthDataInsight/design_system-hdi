# frozen_string_literal: true

require 'test_helper'

module DesignSystem
  module Hdi
    module Builders
      # This tests the hdi button builder
      class ButtonTest < ActionView::TestCase
        include DesignSystemHelper

        setup do
          @brand = 'hdi'
          @controller.stubs(:brand).returns(@brand)
        end

        test 'rendering hdi primary button' do
          @output_buffer = ds_button_tag('Click', style: 'primary', 'data-id': 1)

          assert_select('button.hdi-button', text: 'Click')
          assert_select 'button[data-id]', true, 'Expected button with passed data-attribute option'
        end

        test 'rendering hdi styled buttons' do
          {
            'secondary' => 'hdi-button--secondary',
            'warning' => 'hdi-button--warning',
            'reverse' => 'hdi-button--reverse'
          }.each do |style, modifier|
            @output_buffer = ds_button_tag('Go', style:)
            assert_select("button.hdi-button.#{modifier}", text: 'Go')
          end
        end

        test 'rendering hdi disabled button' do
          @output_buffer = ds_button_tag('Reset', disabled: true)

          assert_select('button.hdi-button[disabled]', text: 'Reset')
          assert_select('button[aria-disabled="true"]')
        end
      end
    end
  end
end
