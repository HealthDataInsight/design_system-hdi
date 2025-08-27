# frozen_string_literal: true

module DesignSystem
  module Hdi
    module Builders
      # This class is used to provide will_paginate renderer for HDI.
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
              previous_icon + title,
              href: url(target),
              class: "#{brand}-pagination-item #{brand}-pagination-item--previous")
        end

        def link_with_next_title(target)
          title = tag(:span, 'Next', class: "#{brand}-pagination-item-title")
          tag(:a,
              title + next_icon,
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

        # Tailwind icons
        def next_icon
          %(
            <svg class="#{brand}-icon" viewBox="0 0 20 20" fill="currentColor"
            aria-hidden="true" data-slot="icon">
              <path fill-rule="evenodd" d="M2 10a.75.75 0 0 1 .75-.75h12.59l-2.1-1.95a.75.75 0 1 1 1.02-1.1l3.5
              3.25a.75.75 0 0 1 0 1.1l-3.5 3.25a.75.75 0 1 1-1.02-1.1l2.1-1.95H2.75A.75.75 0 0 1 2 10Z"
              clip-rule="evenodd" />
            </svg>
          )
        end

        def previous_icon
          %(
            <svg class="#{brand}-icon" viewBox="0 0 20 20" fill="currentColor"
            aria-hidden="true" data-slot="icon">
              <path fill-rule="evenodd" d="M18 10a.75.75 0 0 1-.75.75H4.66l2.1 1.95a.75.75 0 1 1-1.02
              1.1l-3.5-3.25a.75.75 0 0 1 0-1.1l3.5-3.25a.75.75 0 1 1 1.02 1.1l-2.1 1.95h12.59A.75.75 0 0 1 18 10Z"
              clip-rule="evenodd" />
            </svg>
          )
        end
      end
    end
  end
end
