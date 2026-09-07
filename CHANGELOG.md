# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added grouped HDI sidebar navigation: items with an `options[:group]` label are rendered under collapsible (`<details>`) section headings
- Added the paragraph builder to mirror `design_system`'s `ds_paragraph`
- Added the inset text builder, inheriting the NHS UK implementation
- Added the grid builder, inheriting the generic implementation
- Added the code builder, inheriting the generic implementation
- Added the action link component
- Added the details component
- Added an adapter for Health Data Insight (HDI)

### Changed

- Moved HDI breadcrumb home/divider icons from inline SVG markup into `hdi-frontend` CSS (`::before`), matching GOV.UK/NHS separators and `.hdi-back-link`
- Moved HDI pagination prev/next arrows from inline SVG into `hdi-frontend` CSS (`::before` / `::after`); markup structure stays HDI-specific
- Migrated remaining HDI PORO builders (`button`, `grid`, `paragraph`, `inset_text`, `link`, `notification`/`alert`, `summary_list`, `tab`, `table`, breadcrumbs) to ViewComponents to match `design_system` 0.15.0; empty subclasses inherit parent markup where HDI structure matches
- Made `FixedElements` an empty NHS UK subclass (caption-m comes from GOV.UK headings)
- Updated `design_system` dependency to `~> 0.15.0`
- Migrated the HDI `panel`, `callout`, `details`, `heading`, and `action_link` adapters from PORO builders to ViewComponents, and added `list` and `start_button` components, to match `design_system` 0.14.0 (no API change)
- Updated `render_notice` to accept `content_heading:` (replacing `header:`) and render it, matching the `design_system` 0.14.0 notification API
- Updated `render_alert` and `render_notice` signatures to match `design_system` 0.11.0+ API, adding block support and keyword arguments

[unreleased]: https://github.com/HealthDataInsight/structured_store/compare/...HEAD
