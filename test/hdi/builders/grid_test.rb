# frozen_string_literal: true

require 'test_helper'

module DesignSystem
  module Hdi
    module Builders
      # This tests the hdi grid builder
      class GridTest < ActionView::TestCase
        include DesignSystemHelper

        setup do
          @brand = 'hdi'
          @controller.stubs(:brand).returns(@brand)
        end

        test 'should render block of content' do
          @output_buffer = ds_grid do |grid|
            grid.add_column(:two_thirds) do
              content_tag(:p, 'Test content')
            end
          end

          assert_select "div.#{@brand}-grid-row" do
            assert_select "div.#{@brand}-grid-column-two-thirds" do
              assert_select 'p', text: 'Test content'
            end
          end
        end

        test 'should render multiple columns' do
          @output_buffer = ds_grid do |grid|
            grid.add_column(:two_thirds) do
              content_tag(:p, 'Two thirds content')
            end
            grid.add_column(:one_third) do
              content_tag(:p, 'One third content')
            end
          end

          assert_select "div.#{@brand}-grid-row" do
            assert_select "div.#{@brand}-grid-column-two-thirds", text: /Two thirds content/
            assert_select "div.#{@brand}-grid-column-one-third", text: /One third content/
          end
        end

        test 'should raise an error if total width exceeds 100%' do
          error = assert_raises(ArgumentError) do
            ds_grid do |grid|
              grid.add_column(:two_thirds) { content_tag(:p, 'a') }
              grid.add_column(:two_thirds) { content_tag(:p, 'b') }
            end
          end

          assert_equal 'Total grid width exceeds 100%', error.message
        end
      end
    end
  end
end
