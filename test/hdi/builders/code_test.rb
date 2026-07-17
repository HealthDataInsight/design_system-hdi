# frozen_string_literal: true

require 'test_helper'

module DesignSystem
  module Hdi
    module Builders
      # This tests the hdi code builder
      class CodeTest < ActionView::TestCase
        include DesignSystemHelper

        setup do
          @brand = 'hdi'
          @controller.stubs(:brand).returns(@brand)
        end

        test 'rendering hdi code block' do
          @output_buffer = ds_code('puts "hello"', 'ruby')

          assert_select 'div.app-example__code' do
            assert_select 'button.app-example__copy-button', text: 'Copy'
            assert_select 'pre code.hljs.language-ruby', text: 'puts "hello"'
          end
        end
      end
    end
  end
end
