# These are HDI specific view helper methods
module HdiHelper
  # Groups sidebar navigation items by their optional `options[:group]` label.
  # Ungrouped items come first, then each group in first-seen order. Returns an
  # array of { heading:, icon:, items: } hashes for the sidebar to render; the
  # heading icon is taken from the group's first `options[:group_icon]`.
  def hdi_navigation_groups(items)
    grouped = Array(items).group_by { |item| item.dig(:options, :group) }
    ungrouped = grouped.delete(nil)

    groups = grouped.map do |heading, group_items|
      { heading: heading, icon: group_items.first&.dig(:options, :group_icon), items: group_items }
    end
    groups.unshift(heading: nil, icon: nil, items: ungrouped) if ungrouped.present?
    groups
  end

  def hdi_sidebar_navigation_svg(item)
    path = item[:path]
    active = current_page?(path)
    options = (item[:options] || {}).except(:icon, :group, :group_icon)

    options[:class] = Array(options[:class]) + ['sidebar-item']
    options[:class] << 'sidebar-item--active' if active

    link_to(path, **options) do
      icon = hdi_navigation_icon(item.dig(:options, :icon))
      icon ? icon + item[:label] : item[:label]
    end
  end

  # Renders a heroicon <img> for a sidebar row, or nothing when no icon is set.
  def hdi_navigation_icon(icon_name)
    return if icon_name.blank?

    svg_path = "/design_system/static/heroicons-2.1.5/icon-#{icon_name}.svg"
    content_tag(:img, nil, src: svg_path, class: 'hdi-icon', 'aria-hidden': 'true')
  end
end
