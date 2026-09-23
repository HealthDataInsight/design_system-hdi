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
      icon = hdi_icon(item.dig(:options, :icon))
      icon ? icon + item[:label] : item[:label]
    end
  end

  # Renders a heroicon <img> by name (e.g. "users", "clipboard-document-list"),
  # or nothing when no name is given. Single source of the static icon path,
  # shared by helpers and builders (via the view context).
  def hdi_icon(name, css_class: 'hdi-icon')
    return if name.blank?

    content_tag(:img, nil,
                src: "/design_system/static/heroicons-2.1.5/icon-#{name}.svg",
                class: css_class, 'aria-hidden': 'true')
  end

  # Official HDI wordmark used by the app sidebar and marketing navbar.
  def hdi_logo_src
    '/design_system/static/hdi-frontend-0.12.0/logos/health-data-insight-logo.png'
  end

  def hdi_logo_tag(css_class: 'sidebar-logo', alt: '')
    tag.img(src: hdi_logo_src, class: css_class, alt: alt)
  end

  def ds_media_placeholder(label: nil, variant: :default)
    render DesignSystem::Hdi::MediaPlaceholderComponent.new(label:, variant:)
  end

  def ds_card(**kwargs)
    render DesignSystem::Hdi::CardComponent.new(**kwargs)
  end

  def ds_card_grid(heading: nil, link_label: nil, link_href: nil, tone: :default, items: [])
    render DesignSystem::Hdi::CardGridComponent.new(heading:, link_label:, link_href:, tone:, items:)
  end

  def ds_carousel(label: nil, variant: :default, items: [], &block)
    component = DesignSystem::Hdi::CarouselComponent.new(label:, variant:, items:)
    return render(component) unless block

    render(component) { capture(&block) }
  end

  def ds_partner_grid(heading: nil, intro: nil, tags: [], featured: [], groups: [])
    render DesignSystem::Hdi::PartnerGridComponent.new(heading:, intro:, tags:, featured:, groups:)
  end

  def ds_tag(label, href = nil, facet: :keyword, active: false)
    render DesignSystem::Hdi::TagComponent.new(label, href, facet:, active:)
  end

  def ds_stats(items = [])
    render DesignSystem::Hdi::StatsComponent.new(items)
  end

  def ds_steps(items = [], orientation: :horizontal, progress: :through, interactive: false)
    render DesignSystem::Hdi::StepsComponent.new(items, orientation:, progress:, interactive:)
  end

  def ds_service_spine(items = [], interval: 5_000, label: 'What we do')
    render DesignSystem::Hdi::ServiceSpineComponent.new(items, interval:, label:)
  end

  def ds_hero(title:, lede: nil, primary: nil, secondary: nil, media_label: nil,
              background_image: nil, &block)
    component = DesignSystem::Hdi::HeroComponent.new(
      title:, lede:, primary:, secondary:, media_label:, background_image:
    )
    return render(component) unless block

    render(component) { capture(&block) }
  end

  def ds_navbar(items: [], cta: nil, home_href: '/', search_href: nil)
    render DesignSystem::Hdi::NavbarComponent.new(items:, cta:, home_href:, search_href:)
  end

  def ds_cta_band(title:, lede: nil, primary: nil, secondary: nil, tone: :contrast)
    render DesignSystem::Hdi::CtaBandComponent.new(title:, lede:, primary:, secondary:, tone:)
  end

  def ds_site_footer(links: nil, copyright: nil)
    render DesignSystem::Hdi::SiteFooterComponent.new(links:, copyright:)
  end
end

