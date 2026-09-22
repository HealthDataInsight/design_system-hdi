# frozen_string_literal: true

module Website
  class ServicesController < BaseController
    def show
      @service = Website::Catalog.service(params[:slug])
      raise ActionController::RoutingError, 'Not Found' unless @service

      @services = Website::Catalog.services
      @projects = Website::Catalog.projects_for_service(@service['slug'])
      @partners = Website::Catalog.partners_for_service(@service['slug'])
      @page_title = "#{@service['name']} — Health Data Insight"
    end
  end
end
