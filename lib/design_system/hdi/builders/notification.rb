# frozen_string_literal: true

module DesignSystem
  module Hdi
    module Builders
      # This class provides HDI methods to display notifications.
      class Notification < ::DesignSystem::Generic::Builders::Notification
        def render_alert(msg = nil, &block)
          content = block ? capture(&block) : msg

          content_tag(:div, class: "#{brand}-notification-banner #{brand}-notification-banner__alert",
                            role: 'alert') do
            alert_header + alert_content(content)
          end
        end

        private

        def alert_header
          content_tag(:div, class: "#{brand}-notification-banner__header") do
            content_tag(:h2, 'Alert', class: "#{brand}-notification-banner__title")
          end
        end

        def alert_content(msg)
          content_tag(:div, class: "#{brand}-notification-banner__content") do
            content_tag(:span, sanitize(msg, tags: %w[b p br a], attributes: %w[href target]), 'data-test': 'alert')
          end
        end
      end
    end
  end
end
