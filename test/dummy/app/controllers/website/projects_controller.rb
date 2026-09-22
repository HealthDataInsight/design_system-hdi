# frozen_string_literal: true

module Website
  class ProjectsController < BaseController
    def index
      @filter_service = params[:service]
      @filter_keyword = params[:keyword]
      @projects = filtered_projects
      @services = Website::Catalog.services
      @page_title = 'Our work — Health Data Insight'
    end

    def show
      @project = Website::Catalog.project(params[:slug])
      raise ActionController::RoutingError, 'Not Found' unless @project

      @service = Website::Catalog.service(@project['primary_service'])
      @related = Website::Catalog.related_projects(@project)
      @page_title = "#{@project['name']} — Health Data Insight"
    end

    private

    def filtered_projects
      if @filter_service.present?
        Website::Catalog.projects_for_service(@filter_service)
      elsif @filter_keyword.present?
        Website::Catalog.projects_for_keyword(@filter_keyword)
      else
        Website::Catalog.projects
      end
    end
  end
end
