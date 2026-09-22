# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added `ServiceSpineComponent` (`ds_service_spine`) for the homepage “What we do” section: one full-width indigo service panel at a time, driven by step markers with click, swipe, and auto-advance (paused for `prefers-reduced-motion`)
- Added public-site components wrapping daisyUI where the frontend already ships it: media card, card grid, carousel, partner grid, tag, stats, steps, hero, CTA band, navbar and site footer
- Added a marketing `website` layout (top nav + footer, no app sidebar) and a dummy HDI website preview driven from YAML fixtures
- Added grouped HDI sidebar navigation: items with an `options[:group]` label are rendered under collapsible (`<details>`) section headings
- Added the paragraph builder to mirror `design_system`'s `ds_paragraph`
- Added the inset text builder, inheriting the NHS UK implementation
- Added the grid builder, inheriting the generic implementation
- Added the code builder, inheriting the generic implementation
- Added the action link component
- Added the details component
- Added an adapter for Health Data Insight (HDI)

### Changed

- Website layout uses the established HDI footer (`.hdi-footer-container` / `DesignSystem::Branded` links + copyright) via `SiteFooterComponent`; removed the multi-column deeper-indigo marketing footer slab
- CTA band stays an in-page section above the footer, with a primary purple border so it reads as distinct from footer chrome
- Homepage / trust “How we handle data” uses a 2×2 grid of indigo governance cards (box-links to trust anchors) instead of a soft stacked panel
- Partner logo carousels auto-scroll continuously with faded prev/next controls (paused for `prefers-reduced-motion`); scrollbars and row hairlines removed; featured NHS England / NDRS marks enlarged
- Tab panel content wrapper is a `div` rather than a `p`, so panels can hold block content such as details
- Moved HDI breadcrumb home/divider icons from inline SVG markup into `hdi-frontend` CSS (`::before`), matching GOV.UK/NHS separators and `.hdi-back-link`
- Migrated remaining HDI PORO builders (`button`, `grid`, `paragraph`, `inset_text`, `link`, `notification`/`alert`, `summary_list`, `tab`, `table`, breadcrumbs) to ViewComponents to match `design_system` 0.15.1; empty subclasses inherit parent markup where HDI structure matches
- Made `FixedElements` an empty NHS UK subclass (caption-m comes from GOV.UK headings)
- Updated `design_system` dependency to `~> 0.15.1`
- Migrated the HDI `panel`, `callout`, `details`, `heading`, and `action_link` adapters from PORO builders to ViewComponents, and added `list` and `start_button` components, to match `design_system` 0.14.0 (no API change)
- Updated `render_notice` to accept `content_heading:` (replacing `header:`) and render it, matching the `design_system` 0.14.0 notification API
- Updated `render_alert` and `render_notice` signatures to match `design_system` 0.11.0+ API, adding block support and keyword arguments

[unreleased]: https://github.com/HealthDataInsight/structured_store/compare/...HEAD
