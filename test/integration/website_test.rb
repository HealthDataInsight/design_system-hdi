# frozen_string_literal: true

require 'test_helper'

class WebsiteTest < ActionDispatch::IntegrationTest
  test 'homepage renders fixture-driven work and partner sections' do
    get website_root_path

    assert_response :success
    assert_select 'h1', text: /We make health data useful/
    assert_select '.hdi-hero--image[style*=britain-rivers]'
    assert_select '.hdi-hero--image .hdi-media-placeholder', count: 0
    assert_select '.hdi-media-card', minimum: 3
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

  test 'trust page renders governance cards with anchors' do
    get website_trust_path

    assert_response :success
    assert_select 'h1', text: 'Trust & governance'
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
    assert_select '.hdi-chip-row a.badge.is-active[aria-current="page"]', text: 'All'
    assert_select '.hdi-chip-row a.badge', text: 'Data & Analytics'
    assert_select '.hdi-media-card', minimum: 1

    get website_work_path(service: 'data-and-analytics')

    assert_response :success
    assert_select 'h1', text: /Data & Analytics/
    assert_select '.hdi-chip-row a.badge.is-active[aria-current="page"]', text: 'Data & Analytics'
    assert_select '.hdi-chip-row a.badge[href=?]', website_work_path, text: 'All'
    assert_select '.hdi-media-card', minimum: 1
  end

  test 'our work shows an active keyword chip when filtered by keyword' do
    get website_work_path(keyword: 'synthetic-data')

    assert_response :success
    assert_select 'h1', text: /Synthetic data/
    assert_select '.hdi-chip-row a.badge.is-active[aria-current="page"]', text: 'Synthetic data'
    assert_select '.hdi-chip-row a.badge[href=?]', website_work_path, text: 'All'
    assert_select '.hdi-media-card', minimum: 1
  end

  test 'contact form accepts an enquiry' do
    post website_contact_path, params: {
      website_enquiry: { name: 'Alex', message: 'We need a dataset', organisation: 'NHS' }
    }

    assert_redirected_to website_contact_path
    follow_redirect!
    assert_match(/reply within 3 working days/i, response.body)
  end

  test 'contact form redisplays when required fields are missing' do
    post website_contact_path, params: { website_enquiry: { name: '', message: '' } }

    assert_response :unprocessable_entity
    assert_select 'form'
  end
end
