# frozen_string_literal: true

module DesignSystem
  module Hdi
    module Builders
      # This class provides HDI methods to display notifications.
      class Notification < ::DesignSystem::Generic::Builders::Notification
        # In this instance the string is safe, because it contains known text.
        # rubocop:disable Rails/OutputSafety
        ALERT_SVG = <<~SVG.html_safe
          <svg class="hdi-icon hdi-icon__exclamation-circle" viewBox="0 0 24 24" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="m11.25 11.25.041-.02a.75.75 0 0 1 1.063.852l-.708 2.836a.75.75 0 0 0 1.063.853l.041-.021M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9-3.75h.008v.008H12V8.25Z" />
          </svg>
        SVG

        NOTICE_SVG = <<~SVG.html_safe
          <svg class="hdi-icon hdi-icon__information-circle" viewBox="0 0 24 24" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m9-.75a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 3.75h.008v.008H12v-.008Z" />
          </svg>
        SVG
        # rubocop:enable Rails/OutputSafety

        def render_alert(msg = nil, &block)
          content = block ? capture(&block) : msg
          buffer = ActiveSupport::SafeBuffer.new

          buffer.concat(
            content_tag(:div, class: "#{brand}-notification-banner #{brand}-notification-banner__alert",
                              role: 'alert') do
              ALERT_SVG + text_alert_content(content)
            end
          )
          buffer
        end

        def render_notice(msg = nil, type: :information, content_heading: { text: nil, tag: :h3 }, &block)
          content = block ? capture(&block) : msg
          buffer = ActiveSupport::SafeBuffer.new

          buffer.concat(
            content_tag(:div, class: "#{brand}-notification-banner") do
              NOTICE_SVG + render_notice_block(content, content_heading)
            end
          )

          buffer
        end

        private

        # Heading and body share a content column beside the icon, so the heading
        # sits on its own row above the body instead of inline next to it.
        def render_notice_block(content, content_heading)
          content_tag(:div, class: "#{brand}-notification-banner__content") do
            render_content_heading(content_heading) + text_notice_content(content)
          end
        end

        def render_content_heading(content_heading)
          return ActiveSupport::SafeBuffer.new unless content_heading.is_a?(Hash) && content_heading[:text].present?

          content_tag(content_heading[:tag] || :h3, content_heading[:text],
                      class: "#{brand}-notification-banner__heading")
        end

        def text_alert_content(msg)
          content_tag(:span, 'data-test': 'alert') do
            sanitize(msg, tags: %w[b p br a], attributes: %w[href targ])
          end
        end

        def text_notice_content(msg)
          content_tag(:span, 'data-test': 'notice') do
            sanitize(msg, tags: %w[b p br a], attributes: %w[href targ])
          end
        end
      end
    end
  end
end
