# frozen_string_literal: true

module DesignSystem
  module Hdi
    module Builders
      # This class provides HDI methods to display code blocks.
      class Code < ::DesignSystem::Generic::Builders::Code
        def render_code(code, language)
          content_tag(:div, class: 'hdi-code-container', data: { controller: 'ds--clipboard' }) do
            render_code_heading(language) + render_code_console(code, language)
          end
        end

        private

        def render_code_heading(language)
          content_tag(:div, class: 'hdi-code-heading') do
            content_tag(:span, language.to_s.capitalize) +
              content_tag(:button, class: 'hdi-clipboard-button', data: { action: 'click->ds--clipboard#copy' }) do
                @context.hdi_icon('clipboard-document-list', css_class: 'hdi-clipboard-button__icon') +
                  content_tag(:span, 'Copy', class: 'hdi-clipboard-button__label',
                                             data: { 'ds--clipboard-target': 'buttonText' })
              end
          end
        end

        def render_code_console(code, language)
          content_tag(:pre, class: 'hdi-code-console', data: { 'ds--clipboard-target': 'source' }) do
            content_tag(:code, code, class: "language-#{language} hljs",
                                     data: { controller: 'ds--code-highlight' })
          end
        end
      end
    end
  end
end
