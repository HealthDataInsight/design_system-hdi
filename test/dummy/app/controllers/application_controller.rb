require 'will_paginate/array'
require 'nokogiri'

# This is the application controller
class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session if Rails.env.test?

  include DesignSystem::Branded

  helper HdiHelper

  DESIGN_SYSTEM_SECTIONS = {
    'styles' => 'book-open',
    'components' => 'rectangle-group',
    'utilities' => 'wrench'
  }.freeze

  before_action :add_navigation, :set_service_name, :set_footer_links, :searchbar_url
  helper_method :brand

  private

  def add_navigation
    add_navigation_item('Manage Assistants', assistants_path, icon: 'users')

    add_navigation_item('GOV.UK', url_for(brand: 'govuk'), icon: 'ellipsis-horizontal-circle')
    add_navigation_item('NHS', url_for(brand: 'nhsuk'), icon: 'ellipsis-horizontal-circle')
    add_navigation_item('HDI', url_for(brand: 'hdi'), icon: 'ellipsis-horizontal-circle')

    add_design_system_navigation if brand == 'hdi'
  end

  # Populates the HDI sidebar with the design system showcase by reusing the
  # per-section `_sidebar` partials: each is rendered and its links are turned
  # into HDI-native grouped navigation items. This keeps a single source of
  # truth for the item list while rendering it in HDI's own sidebar style.
  def add_design_system_navigation
    DESIGN_SYSTEM_SECTIONS.each do |section, icon|
      fragment = Nokogiri::HTML.fragment(render_to_string(partial: "#{section}/sidebar"))

      fragment.css('a').each do |link|
        next if link['href'].blank?

        add_navigation_item(link.text.strip, link['href'], group: section.titleize, group_icon: icon)
      end
    end
  end

  def brand
    session[:brand] ||= 'hdi'
    session[:brand] = params[:brand] if params[:brand]
    session[:brand]
  end

  def set_service_name
    @service_name = 'Design system'
  end

  def set_footer_links
    add_footer_link('Custom Link', '#', target: '_blank', rel: 'noopener')
    add_footer_link('Another Link', '#')
    self.copyright_notice = 'Copyright © 2025 Health Data Insight CIC'
  end

  def searchbar_url
    @searchbar_url = nil # Default is nil (hidden)
  end

  def demo_paginated_assistants
    [
      Assistant.new(title: '1'),
      Assistant.new(title: '2'),
      Assistant.new(title: '3')
    ].paginate(page: params[:page], per_page: 1)
  end
end
