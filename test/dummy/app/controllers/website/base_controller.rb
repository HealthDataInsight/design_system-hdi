# frozen_string_literal: true

module Website
  class BaseController < ApplicationController
    layout 'website'
    skip_before_action :add_navigation
    before_action :set_page_title

    helper WebsiteHelper

    private

    def set_page_title
      @page_title = 'Health Data Insight'
    end

    # Public-site support links for the established HDI footer
    # (.hdi-footer-container), same API as DesignSystem::Branded#add_footer_link.
    def set_footer_links
      add_footer_link('About', website_about_path)
      add_footer_link('People', website_people_path)
      add_footer_link('News', website_news_path)
      add_footer_link('Publications', website_publications_path)
      add_footer_link('Trust & governance', website_trust_path)
      add_footer_link('Internships', website_internships_path)
      add_footer_link('Privacy', website_privacy_path)
      add_footer_link('Talk to us', website_contact_path)
      self.copyright_notice = 'Copyright © 2025 Health Data Insight CIC'
    end
  end
end
