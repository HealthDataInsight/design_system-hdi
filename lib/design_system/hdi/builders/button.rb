# frozen_string_literal: true

module DesignSystem
  module Hdi
    module Builders
      # This class provides methods to render HDI button.
      class Button < ::DesignSystem::Generic::Builders::Button
        def render_button(content_or_options = nil, options = nil, &)
          options = prep_button_options(content_or_options, options)
          options[:class] = "#{brand}-button"

          options = css_class_options_merge(options) do |button_classes|
            button_classes << style_class_hash[options['style']]
            button_classes << "#{brand}-button--disabled" if options['disabled']
          end

          if block_given?
            button_tag(options = nil, &)
          else
            button_tag(content_or_options, options)
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
end
