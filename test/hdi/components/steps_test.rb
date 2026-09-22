# frozen_string_literal: true

require 'test_helper'

module DesignSystem
  module Hdi
    module Components
      class StepsTest < ActionView::TestCase
        include DesignSystemHelper
        include HdiHelper

        setup do
          @brand = 'hdi'
          @controller.stubs(:brand).returns(@brand)
        end

        test 'marks steps up to the current one as primary by default' do
          @output_buffer = ds_steps([
                                      { name: 'TRANSFORM', content: '1' },
                                      { name: 'CONNECT', content: '2', current: true },
                                      { name: 'BUILD', content: '3' }
                                    ])

          assert_select 'ul.steps.hdi-steps' do
            assert_select 'li.step.step-primary', count: 2
            assert_select 'li.step', count: 3
            assert_select '.hdi-steps__current', count: 0
            assert_select 'input.hdi-steps__input', count: 0
          end
        end

        test 'marks only the current step as primary when progress is current' do
          @output_buffer = ds_steps([
                                      { name: 'TRANSFORM', content: '1' },
                                      { name: 'CONNECT', content: '2', current: true },
                                      { name: 'BUILD', content: '3' }
                                    ], progress: :current)

          assert_select 'ul.steps.hdi-steps.hdi-steps--current' do
            assert_select 'li.step.step-primary', count: 1
            assert_select 'li.step.step-primary', text: /CONNECT/
            assert_select 'li.step:not(.step-primary)', count: 2
            assert_select '.hdi-steps__current', count: 0
          end
        end

        test 'interactive steps use radios and disclose captions without primary progress' do
          @output_buffer = ds_steps([
                                      { name: 'Scope the question', caption: 'A conversation, not a procurement.', content: '1' },
                                      { name: 'Test the options', caption: 'What the data can support.', content: '2' }
                                    ], interactive: true)

          assert_select 'ul.steps.hdi-steps.hdi-steps--interactive[role="radiogroup"]' do
            assert_select 'li.step.step-primary', count: 0
            assert_select 'input.hdi-steps__input[type="radio"]', count: 2
            assert_select 'input.hdi-steps__input[checked]', count: 0
            assert_select '.hdi-steps__caption', text: /A conversation, not a procurement/
            assert_select '.hdi-steps__caption', text: /What the data can support/
            assert_select '.hdi-steps__current', count: 0
          end
        end

        test 'interactive steps honour a preselected current without sequential primaries' do
          @output_buffer = ds_steps([
                                      { name: 'Scope', caption: 'First', content: '1' },
                                      { name: 'Test', caption: 'Second', content: '2', current: true }
                                    ], interactive: true)

          assert_select 'ul.hdi-steps--interactive' do
            assert_select 'li.step.step-primary', count: 0
            assert_select 'input.hdi-steps__input[checked]', count: 1
            assert_select 'input.hdi-steps__input[checked][value="1"]'
          end
        end

        test 'vertical steps wrap name and caption in one copy cell' do
          @output_buffer = ds_steps([
                                      { name: 'Phase 1', caption: '2016–2018 — First release.', current: true },
                                      { name: 'Phase 2', caption: 'Next.' }
                                    ], orientation: :vertical)

          assert_select 'ul.steps.hdi-steps.steps-vertical' do
            assert_select 'li.step .hdi-steps__copy', count: 2
            assert_select 'li.step.step-primary .hdi-steps__copy .hdi-steps__caption',
                          text: /2016–2018 — First release/
            assert_select 'input.hdi-steps__input', count: 0
          end
        end
      end
    end
  end
end
