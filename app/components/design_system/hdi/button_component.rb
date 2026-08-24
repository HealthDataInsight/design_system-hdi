# frozen_string_literal: true

module DesignSystem
  module Hdi
    # HDI button: uses `--reverse` (not `--inverse`) and adds a `--disabled`
    # modifier class alongside the native disabled attribute.
    class ButtonComponent < DesignSystem::Generic::ButtonComponent
      def call
        button_options = prep_button_options(content_or_options, options)
        style = button_options.delete('style')
        button_options['aria-disabled'] = true if button_options['disabled']
        button_options = css_class_options_merge(button_options, ["#{brand}-button"]) do |classes|
          style_class = style_class_hash[style]
          classes << style_class if style_class
          classes << "#{brand}-button--disabled" if button_options['disabled']
        end
        if content.present?
          button_tag(button_options) { content }
        else
          button_tag(content_or_options, button_options)
        end
      end

      private

      def style_class_hash
        {
          'secondary' => "#{brand}-button--secondary",
          'warning' => "#{brand}-button--warning",
          'reverse' => "#{brand}-button--reverse"
        }
      end
    end
  end
end
