# frozen_string_literal: true

module DesignSystem
  module Hdi
    # HDI alert: an icon-led notification banner rather than the generic
    # error-summary used by GOV.UK / NHS UK.
    class AlertComponent < DesignSystem::Generic::AlertComponent
      def call
        content_tag(:div,
                    class: "#{brand}-notification-banner #{brand}-notification-banner__alert",
                    role: 'alert',
                    'aria-labelledby': "#{brand}-notification-banner-alert-title") do
          alert_header + alert_content(body)
        end
      end

      private

      def alert_header
        content_tag(:div, class: "#{brand}-notification-banner__header") do
          content_tag(:h2, 'Alert', class: "#{brand}-notification-banner__title",
                                    id: "#{brand}-notification-banner-alert-title")
        end
      end

      def alert_content(msg)
        content_tag(:div, class: "#{brand}-notification-banner__content") do
          content_tag(:span, sanitize(msg.to_s, tags: %w[b p br a], attributes: %w[href target]),
                      'data-test': 'alert')
        end
      end
    end
  end
end
