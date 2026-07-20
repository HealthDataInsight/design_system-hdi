# frozen_string_literal: true

require 'test_helper'

module DesignSystem
  module Hdi
    module Builders
      # This tests the hdi paragraph builder
      class ParagraphTest < ActionView::TestCase
        include DesignSystemHelper

        setup do
          @brand = 'hdi'
          @controller.stubs(:brand).returns(@brand)
        end

        test 'rendering hdi normal paragraph' do
          @output_buffer = ds_paragraph('This is a normal paragraph')

          assert_select("p.#{@brand}-body", text: 'This is a normal paragraph')
        end

        test 'rendering hdi small paragraph' do
          @output_buffer = ds_paragraph('This is a small paragraph', size: :s)

          assert_select("p.#{@brand}-body-s", text: 'This is a small paragraph')
        end

        test 'rendering hdi paragraph with invalid size' do
          assert_raises(ArgumentError) do
            ds_paragraph('This is a paragraph', size: :m)
          end
        end

        test 'rendering hdi paragraph with a block' do
          @output_buffer = ds_paragraph do
            content_tag(:span, 'Block content')
          end

          assert_select("p.#{@brand}-body") do
            assert_select('span', text: 'Block content')
          end
        end
      end
    end
  end
end
