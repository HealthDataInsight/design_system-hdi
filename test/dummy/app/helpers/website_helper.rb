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
      { label: 'Our work', href: website_work_path },
      { label: 'Trust & governance', href: website_trust_path },
      { label: 'About', href: website_about_path }
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

  def project_card(project)
    service = Website::Catalog.service(project['primary_service'])
    {
      title: project['title'],
      eyebrow: service&.fetch('name', nil),
      meta: [project['name'], project['partner_short']].compact.join(' · '),
      href: website_project_path(project['slug']),
      image_label: project['image_label']
    }
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
