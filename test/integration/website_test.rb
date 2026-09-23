# frozen_string_literal: true

require 'test_helper'

class WebsiteTest < ActionDispatch::IntegrationTest
  test 'homepage renders fixture-driven work and partner sections' do
    get website_root_path

    assert_response :success
    assert_select 'h1', text: /We make health data useful/
  assert_select '.hdi-hero--image[style*=britain-rivers]'
  assert_select '.hdi-hero--image[data-controller=hero-reveal]'
  assert_select '.hdi-hero--image .hdi-media-placeholder', count: 0
    assert_select '.hdi-card-grid--dark .hdi-media-card', count: 3
    assert_select '.hdi-card-grid--dark.hdi-section--contrast', count: 0
    assert_select '.hdi-card-grid--light .hdi-media-card', count: 3
    assert_select '.hdi-partner-featured img', count: 2
    assert_select '.hdi-carousel--logos img', minimum: 4
    assert_select '.stat-value', text: '15 years'
    assert_select 'h2', text: 'How we handle data'
    assert_select 'a', text: 'Our governance in full'
    assert_select '.hdi-governance-grid > li > a.hdi-governance-card', count: 4
    assert_select 'a.hdi-governance-card[href=?]', website_trust_path(anchor: 'information-governance')
    assert_select 'a.hdi-governance-card', text: /Information governance/
    assert_select 'section.hdi-cta-band', count: 1
    assert_select 'footer[role=contentinfo] .hdi-footer-container .hdi-footer' do
      assert_select 'a.hdi-footer__list-item-link', text: 'Talk to us'
      assert_select 'p.hdi-footer__copyright', text: /Health Data Insight CIC/
    end
    assert_select '.hdi-site-footer', count: 0
  end

  test 'trust page renders governance copy and credentials' do
    get website_trust_path

    assert_response :success
    assert_select 'h1', text: 'Trust & governance'
    assert_select '.hdi-trust-layout'
    assert_select '.hdi-trust-copy a.hdi-trust-term', text: /NHS Information Governance Framework/
    assert_select '.hdi-trust-copy a.hdi-trust-term', text: /Information Commissioners/
    assert_select '.hdi-trust-badges .hdi-credential-card', count: 4
    assert_select '.hdi-credential-card--reserved', count: 2
    assert_select '.hdi-credential-card__title', text: 'Cyber Essentials'
    assert_select '.hdi-credential-card__title', text: 'Epic Analyst'
    assert_select '.hdi-governance-grid > li > .hdi-governance-card', count: 4
    assert_select '#information-governance.hdi-governance-card'
    assert_select '#partnership-with-ndrs.hdi-governance-card'
    assert_select '#patient-and-public-involvement.hdi-governance-card'
    assert_select '#ethics-and-approvals.hdi-governance-card'
  end

  test 'homepage what we do shows one service panel at a time' do
    get website_root_path

    assert_response :success
    assert_select 'h2', text: 'What we do'
    assert_select '.hdi-service-spine[data-controller="service-spine"]', count: 1
    assert_select '.hdi-service-spine__steps input.hdi-steps__input', count: 4
    assert_select '.hdi-service-spine__steps input.hdi-steps__input[checked]', count: 1
    assert_select '.hdi-service-spine__panel', count: 4
    assert_select '.hdi-service-spine__panel.is-active', count: 1
    assert_select '.hdi-service-spine__panel.is-active .hdi-service-spine__title',
                  text: 'Strategy & Transformation'
    assert_select '.hdi-service-cards', count: 0
  end

  test 'service page renders from fixtures and reuses card and partner grids' do
    get website_service_path('data-and-analytics')

    assert_response :success
    assert_select 'nav[aria-label=Breadcrumb] a.hdi-breadcrumbs__link--home[href=?]', website_root_path
    assert_select 'nav[aria-label=Breadcrumb] a.hdi-breadcrumbs__link', text: 'Data & Analytics'
    assert_select 'h1', text: 'Data & Analytics'
    assert_select '.hdi-steps--current li.step.step-primary', count: 1
    assert_select '.hdi-steps--current li.step.step-primary', text: /CONNECT/
    assert_select '.hdi-steps--current li.step:not(.step-primary)', count: 3
    assert_select '.hdi-steps__current', count: 0
    assert_select '.hdi-reasons h2', text: 'You might be here because'
    assert_select '.hdi-reason-list > .hdi-reason', count: 3
    assert_select 'p', text: /The shape depends on what you're buying/, count: 0
    assert_select '.hdi-steps--interactive[role="radiogroup"]', minimum: 1
    assert_select '.hdi-steps--interactive .hdi-steps__caption', text: /A conversation, not a procurement/
    assert_select '.hdi-media-card', minimum: 1
    assert_select '.hdi-partner-grid h2', text: 'Who we work with on this'
    assert_select '.hdi-partner-grid .hdi-chip-row .badge', minimum: 1
    assert_select '.hdi-partner-grid .hdi-partner-featured', count: 0
    assert_select '.hdi-partner-grid .hdi-carousel--logos img', minimum: 1
    assert_select 'h2', text: /Partners on our/, count: 0
  end

  test 'project page uses the shared card grid for related work' do
    get website_project_path('simulacrum-v2')

    assert_response :success
    assert_select 'nav[aria-label=Breadcrumb] a.hdi-breadcrumbs__link--home[href=?]', website_root_path
    assert_select 'nav[aria-label=Breadcrumb] a.hdi-breadcrumbs__link[href=?]', website_work_path, text: 'Our work'
    assert_select 'nav[aria-label=Breadcrumb] a.hdi-breadcrumbs__link', text: 'Simulacrum v2'
    assert_select 'h1', text: /Synthetic cancer data/
    assert_select '.badge', minimum: 1
    assert_select '.hdi-project-participants .hdi-thumbnail--circle', minimum: 4
    assert_select '.hdi-project-participants a.hdi-thumbnail[href=?]', website_person_path('sophie-jose')
    assert_select '.hdi-media-card', minimum: 1
    assert_select 'h3', text: 'Delivered with'
    assert_select '.hdi-logo--featured img[src="/website/partners/NHS-E-logo.png"]'
    assert_select '.hdi-logo--featured img[src="/website/partners/NDRS-logo.png"]'
    assert_select '.hdi-logo-mark', text: 'NHS England NDRS', count: 0
  end

  test 'our work lists filter chips and can be filtered by service' do
    get website_work_path

    assert_response :success
    assert_select 'nav[aria-label=Breadcrumb] a.hdi-breadcrumbs__link--home[href=?]', website_root_path
    assert_select 'nav[aria-label=Breadcrumb] a.hdi-breadcrumbs__link', text: 'Our work'
    assert_select 'h1', text: 'Our work'
    assert_select '.hdi-work-index__sidebar', text: /Filter/i
    assert_select 'form#work-search input[placeholder=?]', 'Search titles, partners and keywords'
    assert_select '.hdi-work-index__results .hdi-media-card', minimum: 1
    assert_select '.stat-value', minimum: 1
    assert_select '.hdi-cta-band', text: /Not seeing your problem/

    get website_work_path(service: 'data-and-analytics')

    assert_response :success
    assert_select 'input#work-service-data-and-analytics[checked]'
    assert_select '.hdi-work-index__chip', text: /Data & Analytics/
    assert_select '.hdi-work-index__results .hdi-media-card', minimum: 1
  end

  test 'our work shows an active keyword chip when filtered by keyword' do
    get website_work_path(keyword: 'synthetic-data')

    assert_response :success
    assert_select '.hdi-work-index__chip', text: /Synthetic data/
    assert_select 'a.badge.is-active[aria-current="page"]', text: 'Synthetic data'
    assert_select '.hdi-work-index__results .hdi-media-card', minimum: 1
  end

  test 'our work can be searched and paginated' do
    get website_work_path(q: 'simulacrum')

    assert_response :success
    assert_select 'form#work-search input[name=q][value=simulacrum]'
    assert_select '.hdi-work-index__results .hdi-media-card', minimum: 1
    assert_select '.hdi-work-index__chip', text: /simulacrum/i

    get website_work_path(page: 2)

    assert_response :success
    assert_select 'nav.hdi-pagination', minimum: 1
  end

  test 'contact form accepts an enquiry' do
    post website_contact_path, params: {
      website_enquiry: {
        name: 'Alex',
        email: 'alex@example.com',
        message: 'We need a dataset',
        organisation: 'NHS',
        privacy: '1'
      }
    }

    assert_redirected_to website_contact_path
    follow_redirect!
    assert_match(/reply within 3 working days/i, response.body)
  end

  test 'contact form redisplays when required fields are missing' do
    post website_contact_path, params: { website_enquiry: { name: '', message: '', email: '' } }

    assert_response :unprocessable_entity
    assert_select 'form'
  end

  test 'contact page shows form left and sidebar right' do
    get website_contact_path

    assert_response :success
    assert_select 'h1', text: /Tell us your challenge/
    assert_select '.hdi-contact-layout__form form'
    assert_select '.hdi-contact-sidebar', text: /Reach us directly/
    assert_select '.hdi-contact-next', text: /What happens next/
    assert_select 'input[name=?]', 'website_enquiry[email]'
    assert_select 'input[name=?]', 'website_enquiry[privacy]'
  end

  test 'about page shows CIC story and people carousel' do
    get website_about_path

    assert_response :success
    assert_select 'h1', text: /community interest company/i
    assert_select '.hdi-about-hero--image[style*="team.jpg"]'
    assert_select '.hdi-about-principle', count: 2
    assert_select '.hdi-about-diff__card', count: 3
    assert_select '.hdi-carousel--people[data-controller="carousel"]'
    assert_select '.hdi-carousel--people .hdi-person-card--light', minimum: 20
    assert_select '.hdi-carousel--people .hdi-person-card img[src*="/website/people/"]', minimum: 20
    assert_select '.hdi-about-people__count', text: /specialists working from Cambridge and remotely/
    assert_select 'a', text: /Meet the whole team/
    assert_select '.hdi-carousel--people > button.hdi-carousel__control--prev[aria-label="Previous people"]', count: 1
    assert_select '.hdi-carousel--people > button.hdi-carousel__control--next[aria-label="Next people"]', count: 1
    assert_select '.hdi-carousel--people .hdi-carousel__track[data-carousel-target="track"]'
    assert_select 'a.hdi-person-card__link[href=?]', website_person_path('jem-rashbass')
    assert_select '.hdi-about-internships .hdi-inset-text', text: /Applications closed for 2026/
    assert_select '.hdi-governance-grid', count: 0
  end

  test 'news publications people and internships pages render' do
    get website_news_path
    assert_response :success
    assert_select 'h1', text: 'News'

    get website_publications_path
    assert_response :success
    assert_select 'h1', text: 'Publications'
    assert_select '.hdi-navbar__search form.hdi-search-form[action=?]', website_publications_path
    assert_select '.hdi-publications__sidebar', text: /Filter/i
    assert_select '.hdi-publications__filter-heading', text: 'Filter'
    assert_select 'form#publications-search input[placeholder=?]', 'Search titles, authors and journals'
    assert_select '.hdi-publications__item', minimum: 1
    assert_select 'nav.hdi-pagination', minimum: 1
    assert_select '.hdi-cta-band', text: /Planning a study/

    get website_people_path
    assert_response :success
    assert_select 'h1', text: 'People'
    assert_select 'h2', text: 'Directors'
    assert_select 'h2', text: 'Team'
    assert_select 'h2', text: 'Associates'
    assert_select '.hdi-person-card--light', minimum: 20
    assert_select '.hdi-person-card img[src*="/website/people/"]', minimum: 20
    assert_select '.hdi-person-card .hdi-media-placeholder', count: 0
    assert_select '.hdi-person-card__name', text: 'Jem Rashbass'
    assert_select '.hdi-person-card__role', text: 'Chief Executive Officer'
    assert_select '.hdi-person-card__name', text: 'Tim Gentry'
    assert_select '.hdi-person-card__role', text: 'Chief Technology Officer'
    assert_select '.hdi-person-card__name', text: 'Gavin Baily'
    assert_select '.hdi-person-card__name', text: 'Hilary Wilderspin'
    assert_select '.hdi-person-card__name', text: 'Oliver Tulloch'
    assert_select '.hdi-person-card__body .hdi-body', count: 0
    assert_select 'a.hdi-person-card__link[href=?]', website_person_path('jem-rashbass')

    get website_person_path('tim-gentry')
    assert_response :success
    assert_select 'h1', text: 'Tim Gentry'
    assert_select 'img[src="/website/people/Tim-Gentry-Aug-25.jpg"]'
    assert_select 'h2', text: 'Projects'

    get website_internships_path
    assert_response :success
    assert_select 'h1', text: /Internships/

    get website_privacy_path
    assert_response :success
    assert_select 'h1', text: /privacy/i
  end

  test 'publications can be filtered by year and search query' do
    get website_publications_path(year: '2026')

    assert_response :success
    assert_select 'a.hdi-publications__year-btn.is-active', text: '2026'
    assert_select '.hdi-publications__item', minimum: 1
    assert_select '.hdi-publications__title', text: /endometrial cancer/i
    assert_select 'form#publications-search input[name=year][value=2026]'

    get website_publications_path(year: '2025', q: 'synthetic')

    assert_response :success
    assert_select '.hdi-publications__title', text: /Synthetic data/i
    assert_select 'form#publications-search input[name=q][value=synthetic]'
    assert_select 'a.hdi-publications__year-btn.is-active', text: '2025'
  end

  test 'publications can be filtered by type and subject params' do
    get website_publications_path(type: ['Methods paper'], subject: ['Cancer'])

    assert_response :success
    assert_select 'input#pub-type-methods-paper[checked]'
    assert_select 'input#pub-subject-cancer[checked]'
    assert_select '.hdi-publications__item', minimum: 1
    assert_select '.hdi-publications__chip', text: /Methods paper/
    assert_select '.hdi-publications__chip', text: /Cancer/
  end

  test 'publications pagination preserves filters' do
    get website_publications_path(page: 2)

    assert_response :success
    assert_select '.hdi-publications__item', minimum: 1
    assert_select 'nav.hdi-pagination a.hdi-pagination-item[href*=page]'

    get website_publications_path(q: 'cancer')

    assert_response :success
    assert_select 'nav.hdi-pagination a[href*="q=cancer"]'
  end

  test 'publications shows empty state when nothing matches' do
    get website_publications_path(q: 'zzzz-no-match')

    assert_response :success
    assert_select '.hdi-publications__empty', text: /No publications matched/
    assert_select '.hdi-publications__item', count: 0
  end
end
