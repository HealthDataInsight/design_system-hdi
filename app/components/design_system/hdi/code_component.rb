# frozen_string_literal: true

module DesignSystem
  module Hdi
    # HDI code block: language heading with clipboard icon, then a console-style
    # pre/code area. Markup differs from the generic app-example chrome.
    class CodeComponent < DesignSystem::Generic::CodeComponent
      def call
        content_tag(:div, class: 'hdi-code-container', data: { controller: 'ds--clipboard' }) do
          heading + console
        end
      end

      private

      def heading
        content_tag(:div, class: 'hdi-code-heading') do
          content_tag(:span, language.to_s.capitalize) +
            content_tag(:button, class: 'hdi-clipboard-button',
                                 data: { action: 'click->ds--clipboard#copy' }) do
              clipboard_icon +
                content_tag(:span, 'Copy', class: 'hdi-clipboard-button__label',
                                           data: { 'ds--clipboard-target': 'buttonText' })
            end
        end
      end

      def clipboard_icon
        content_tag(:img, nil,
                    src: '/design_system/static/heroicons-2.1.5/icon-clipboard-document-list.svg',
                    class: 'hdi-clipboard-button__icon', 'aria-hidden': 'true')
      end

      def console
        content_tag(:pre, class: 'hdi-code-console', data: { 'ds--clipboard-target': 'source' }) do
          content_tag(:code, code, class: "language-#{language} hljs",
                                   data: { controller: 'ds--code-highlight' })
        end
      end
    end
  end
end
