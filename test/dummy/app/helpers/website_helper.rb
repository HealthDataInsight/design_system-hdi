# frozen_string_literal: true

# Navigation and card mapping for the dummy public website.
module WebsiteHelper
  def website_nav_items
    [
      {
        label: 'What we do',
        href: website_service_path(Website::Catalog.services.first.fetch('slug')),
        children: Website::Catalog.services.map do |service|
          { label: service['name'], href: website_service_path(service['slug']) }
        end
      },
      {
        label: 'Our work',
        href: website_work_path,
        children: [
          { label: 'All projects', href: website_work_path },
          { label: 'Publications', href: website_publications_path }
        ]
      },
      { label: 'News', href: website_news_path },
      { label: 'Trust & governance', href: website_trust_path },
      {
        label: 'About',
        href: website_about_path,
        children: [
          { label: 'About HDI', href: website_about_path },
          { label: 'People', href: website_people_path },
          { label: 'Internships', href: website_internships_path }
        ]
      }
    ]
  end

  def website_nav_cta
    { label: 'Talk to us', href: website_contact_path }
  end

  # Homepage / trust “How we handle data” topics. Homepage cards link to
  # matching anchors on the trust page.
  def governance_topics(detail: false)
    [
      {
        title: 'Information governance',
        body: detail ? 'How data is approved, handled and destroyed. The full picture of our current IG practice, in one place.' : 'How data is approved, handled and destroyed.',
        anchor: 'information-governance'
      },
      {
        title: 'Partnership with NDRS',
        body: 'Our formal agreement with the National Disease Registration Service, NHS England.',
        anchor: 'partnership-with-ndrs'
      },
      {
        title: 'Patient and public involvement',
        body: 'Who is in the room when we decide what to do with patient data.',
        anchor: 'patient-and-public-involvement'
      },
      {
        title: 'Ethics and approvals',
        body: 'The approvals each project runs under, named on the project page itself.',
        anchor: 'ethics-and-approvals'
      }
    ]
  end

  # Trust page credential rail: held badges first, then reserved slots for
  # certificates we display once assets / wording are confirmed.
  def trust_credentials
    [
      {
        title: 'Cyber Essentials',
        status: 'Certified',
        mark: :shield,
        reserved: false
      },
      {
        title: 'NHS Data Security and Protection Toolkit',
        status: 'Standards met',
        meta: '2025–26 · valid to 30 June 2027',
        mark: :certificate,
        reserved: false
      },
      {
        title: 'Epic Analyst',
        status: 'Certificate reserved',
        mark: :slot,
        reserved: true
      },
      {
        title: 'CE marking',
        status: 'Certificate reserved',
        mark: :slot,
        reserved: true
      }
    ]
  end

  def project_card(project, include_tags: false)
    service = Website::Catalog.service(project['primary_service'])
    status = project['status_bucket'] || Website::Catalog.project_status_bucket(project['status'])
    meta_parts = [project['name'], project['partner_short'], status].compact
    card = {
      title: project['title'],
      eyebrow: service&.fetch('name', nil),
      meta: meta_parts.join(' · '),
      href: website_project_path(project['slug']),
      image_label: project['image_label']
    }
    return card unless include_tags

    tags = Array(project['keywords']).reject { |tag| tag['facet'].to_s == 'service' }.first(3)
    card[:tags] = tags.map { |tag|
      { label: tag['label'], href: tag_href(tag), facet: tag['facet'] }
    }
    card
  end

  # Logos for the project “Delivered with” sidebar. Falls back to partner_short
  # text when no partner_logos resolve (handled in the view).
  def project_partner_logos(project)
    Website::Catalog.partner_logos_for(project)
  end

  def news_card(item)
    date = item['date']
    date_label = date.respond_to?(:strftime) ? date.strftime('%d %B %Y') : date
    {
      title: item['title'],
      eyebrow: "#{item['kind']} · #{date_label}",
      meta: item['summary'],
      image_label: item['image_label']
    }
  end

  def service_step_items(current_slug = nil)
    Website::Catalog.services.each_with_index.map do |service, index|
      {
        name: service['spine'],
        caption: service['name'],
        href: website_service_path(service['slug']),
        content: (index + 1).to_s,
        current: service['slug'] == current_slug
      }
    end
  end

  # Homepage “What we do” interactive spine: one indigo panel at a time.
  def service_spine_items(services = Website::Catalog.services)
    Array(services).each_with_index.map do |service, index|
      {
        spine: service['spine'],
        name: service['name'],
        summary: service['summary'],
        offerings: service['offerings'],
        href: website_service_path(service['slug']),
        media_label: service['name'],
        content: (index + 1).to_s,
        current: index.zero?
      }
    end
  end

  def tag_href(tag)
    if tag['facet'] == 'service'
      website_work_path(service: tag['slug'])
    else
      website_work_path(keyword: tag['slug'])
    end
  end

  def work_index_heading(service_slug: nil, keyword: nil)
    if service_slug.present?
      service = Website::Catalog.service(service_slug)
      service ? "Our work · #{service['name']}" : 'Our work'
    elsif keyword.present?
      tag = Website::Catalog.keyword(keyword)
      label = tag&.fetch('label', nil) || keyword.tr('-', ' ')
      "Our work tagged “#{label}”"
    else
      'Our work'
    end
  end

  def work_stats_items(stats = @project_stats)
    stats ||= Website::Catalog.project_stats
    [
      { value: stats[:total], description: 'projects' },
      { value: stats[:live], description: 'live' },
      { value: stats[:partners], description: 'partners' }
    ]
  end

  # Query hash for the current Our work filters (no page).
  def work_filter_query(overrides = {})
    query = {}
    query[:q] = @q if @q.present?
    query[:service] = @services_filter if Array(@services_filter).any?
    query[:subject] = @subjects if Array(@subjects).any?
    query[:method] = @methods if Array(@methods).any?
    query[:status] = @statuses if Array(@statuses).any?
    query[:sort] = @sort if @sort.present? && @sort != 'newest'

    merged = query.merge(overrides)
    merged.delete_if do |_key, value|
      value.nil? || (value.respond_to?(:empty?) && value.empty?) || value == false
    end
  end

  def work_path_with(**overrides)
    website_work_path(work_filter_query(overrides))
  end

  def work_clear_filters_path
    website_work_path
  end

  def work_sort_options
    [
      ['Newest first', 'newest'],
      ['Title A–Z', 'title']
    ]
  end

  def work_applied_filter_chips
    chips = []

    Array(@services_filter).each do |slug|
      service = Website::Catalog.service(slug)
      chips << {
        label: service&.fetch('name', nil) || slug.tr('-', ' '),
        href: work_path_with(service: Array(@services_filter) - [slug])
      }
    end

    Array(@subjects).each do |slug|
      tag = Website::Catalog.keyword(slug)
      chips << {
        label: tag&.fetch('label', nil) || slug.tr('-', ' '),
        href: work_path_with(subject: Array(@subjects) - [slug])
      }
    end

    Array(@methods).each do |slug|
      tag = Website::Catalog.keyword(slug)
      chips << {
        label: tag&.fetch('label', nil) || slug.tr('-', ' '),
        href: work_path_with(method: Array(@methods) - [slug])
      }
    end

    Array(@statuses).each do |status|
      chips << {
        label: status,
        href: work_path_with(status: Array(@statuses) - [status])
      }
    end

    if @q.present?
      chips << { label: "“#{@q}”", href: work_path_with(q: nil) }
    end

    chips
  end

  def work_filters_active?
    work_applied_filter_chips.any?
  end

  # Hidden fields so search/sort forms preserve sidebar filters.
  def work_hidden_filter_fields(except: [])
    except = Array(except).map(&:to_sym)
    fields = {}
    fields['service[]'] = @services_filter if Array(@services_filter).any? && !except.include?(:service)
    fields['subject[]'] = @subjects if Array(@subjects).any? && !except.include?(:subject)
    fields['method[]'] = @methods if Array(@methods).any? && !except.include?(:method)
    fields['status[]'] = @statuses if Array(@statuses).any? && !except.include?(:status)
    fields[:sort] = @sort if @sort.present? && @sort != 'newest' && !except.include?(:sort)
    fields[:q] = @q if @q.present? && !except.include?(:q)
    fields
  end

  def work_method_toggle(tag)
    slug = tag['slug']
    active = Array(@methods).include?(slug)
    next_methods = active ? Array(@methods) - [slug] : Array(@methods) + [slug]
    {
      label: tag['label'],
      href: work_path_with(method: next_methods),
      active: active
    }
  end

  # Query hash for the current publications filters (no page).
  def publication_filter_query(overrides = {})
    query = {}
    query[:q] = @q if @q.present?
    query[:year] = @year if @year.present?
    query[:type] = @types if Array(@types).any?
    query[:subject] = @subjects if Array(@subjects).any?
    query[:with_ndrs] = '1' if @with_ndrs
    query[:open_access] = '1' if @open_access
    query[:sort] = @sort if @sort.present? && @sort != 'newest'

    merged = query.merge(overrides)
    merged.delete_if do |_key, value|
      value.nil? || (value.respond_to?(:empty?) && value.empty?) || value == false
    end
  end

  def publication_path_with(**overrides)
    website_publications_path(publication_filter_query(overrides))
  end

  def publication_clear_filters_path
    website_publications_path
  end

  # Year toggle buttons: recent years + optional Earlier. Nil year clears the filter.
  def publication_year_toggles(toggles: nil, selected_year: nil)
    toggles ||= @publication_year_toggles || Website::Catalog.publication_year_toggles
    selected = selected_year.nil? ? @year : selected_year

    buttons = Array(toggles[:years]).map do |year|
      {
        label: year.to_s,
        href: publication_path_with(year: year),
        active: selected.to_s == year.to_s
      }
    end

    if toggles[:earlier]
      buttons << {
        label: 'Earlier',
        href: publication_path_with(year: 'earlier'),
        active: selected.to_s.downcase == 'earlier'
      }
    end

    buttons
  end

  def publication_sort_options
    [
      ['Newest first', 'newest'],
      ['Oldest first', 'oldest'],
      ['Title A–Z', 'title']
    ]
  end

  # Removable chips for active filters on the results column.
  def publication_applied_filter_chips
    chips = []

    Array(@types).each do |type|
      chips << {
        label: type,
        href: publication_path_with(type: Array(@types) - [type])
      }
    end

    Array(@subjects).each do |subject|
      chips << {
        label: subject,
        href: publication_path_with(subject: Array(@subjects) - [subject])
      }
    end

    if @year.present?
      chips << {
        label: @year.to_s.downcase == 'earlier' ? 'Earlier' : @year.to_s,
        href: publication_path_with(year: nil)
      }
    end

    if @with_ndrs
      chips << { label: 'With NDRS', href: publication_path_with(with_ndrs: nil) }
    end

    if @open_access
      chips << { label: 'Open access', href: publication_path_with(open_access: nil) }
    end

    if @q.present?
      chips << { label: "“#{@q}”", href: publication_path_with(q: nil) }
    end

    chips
  end

  def publication_filters_active?
    publication_applied_filter_chips.any?
  end

  # Hidden fields so search/sort forms preserve sidebar filters.
  # Array keys use `type[]` / `subject[]` so Rails parses them as arrays.
  def publication_hidden_filter_fields(except: [])
    except = Array(except).map(&:to_sym)
    fields = {}
    fields[:year] = @year if @year.present? && !except.include?(:year)
    fields['type[]'] = @types if Array(@types).any? && !except.include?(:type)
    fields['subject[]'] = @subjects if Array(@subjects).any? && !except.include?(:subject)
    fields[:with_ndrs] = '1' if @with_ndrs && !except.include?(:with_ndrs)
    fields[:open_access] = '1' if @open_access && !except.include?(:open_access)
    fields[:sort] = @sort if @sort.present? && @sort != 'newest' && !except.include?(:sort)
    fields[:q] = @q if @q.present? && !except.include?(:q)
    fields
  end

  def publication_result_href(item)
    item['doi'].presence || item['pdf'].presence || '#'
  end

  def publication_stats_items(stats = @publication_stats)
    stats ||= Website::Catalog.publication_stats
    [
      { value: stats[:total], description: 'publications' },
      { value: stats[:with_ndrs], description: 'with NDRS' },
      { value: stats[:earliest], description: 'earliest' }
    ]
  end

  # Filter chips for the Our work listing: All, each service, plus any
  # active keyword that is not already covered by a service chip.
  def work_filter_chips(services:, service_slug: nil, keyword: nil)
    chips = [
      {
        label: 'All',
        href: website_work_path,
        facet: :subject,
        active: service_slug.blank? && keyword.blank?
      }
    ]

    Array(services).each do |service|
      chips << {
        label: service['name'],
        href: website_work_path(service: service['slug']),
        facet: :service,
        active: service_slug == service['slug']
      }
    end

    if keyword.present?
      tag = Website::Catalog.keyword(keyword)
      if tag && tag['facet'] != 'service'
        chips << {
          label: tag['label'],
          href: website_work_path(keyword: tag['slug']),
          facet: tag['facet'],
          active: true
        }
      elsif tag.nil?
        chips << {
          label: keyword.tr('-', ' '),
          href: website_work_path(keyword:),
          facet: :subject,
          active: true
        }
      end
    end

    chips
  end
end
