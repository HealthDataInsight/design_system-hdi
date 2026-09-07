# frozen_string_literal: true

module DesignSystem
  module Hdi
    module Builders
      # HDI pagination: flat nav with prev/next containers and numbered links.
      # Arrow icons are drawn in CSS (::before / ::after), not inline SVG.
      class PaginationRenderer < ::DesignSystem::Generic::Builders::PaginationRenderer
        def html_container(html)
          tag(:nav, html, class: "#{brand}-pagination")
        end

        def previous_or_next_page(page, _text, classname, aria_label = nil)
          if classname.include?('previous_page')
            build_pagination_div(page, link_with_prev_title(page), "#{brand}-pagination-item--previous-container",
                                 aria_label)
          elsif classname.include?('next_page')
            build_pagination_div(page, link_with_next_title(page), "#{brand}-pagination-item--next-container",
                                 aria_label)
          end
        end

        private

        def build_pagination_div(page, link, css_class, aria_label)
          return unless page

          tag(:div, link, class: css_class, aria: { label: aria_label })
        end

        def link_with_prev_title(target)
          title = tag(:span, 'Previous', class: "#{brand}-pagination-item-title")
          tag(:a,
              title,
              href: url(target),
              class: "#{brand}-pagination-item #{brand}-pagination-item--previous")
        end

        def link_with_next_title(target)
          title = tag(:span, 'Next', class: "#{brand}-pagination-item-title")
          tag(:a,
              title,
              href: url(target),
              class: "#{brand}-pagination-item #{brand}-pagination-item--next")
        end

        def page_number(page)
          if page == current_page
            tag(:a, page,
                class: "#{brand}-pagination-item #{brand}-pagination-item--active",
                href: '#', aria: { current: 'page' })
          else
            tag(:a, page,
                class: "#{brand}-pagination-item",
                href: url(page))
          end
        end
      end
    end
  end
end
