# frozen_string_literal: true

module Website
  class ProjectsController < BaseController
    PER_PAGE = 9

    def index
      @q = params[:q].to_s.strip.presence
      @sort = params[:sort].to_s.strip.presence || 'newest'
      @services_filter = normalize_list_param(params[:service].presence || params[:services])
      @subjects = normalize_list_param(params[:subject].presence || params[:subjects])
      @methods = normalize_list_param(params[:method].presence || params[:methods])
      @statuses = normalize_list_param(params[:status].presence || params[:statuses])

      # Deep links from project tags: ?keyword=slug maps into subject or method.
      apply_legacy_keyword_param!(params[:keyword])

      @services = Website::Catalog.services
      @subject_tags = Website::Catalog.keywords_for_facet('subject')
      @method_tags = Website::Catalog.keywords_for_facet('method')
      @project_stats = Website::Catalog.project_stats
      @service_counts = Website::Catalog.project_service_counts
      @subject_counts = Website::Catalog.project_subject_counts
      @method_counts = Website::Catalog.project_method_counts
      @status_counts = Website::Catalog.project_status_counts

      items = Website::Catalog.project_items(
        services: @services_filter,
        subjects: @subjects,
        methods: @methods,
        statuses: @statuses,
        q: @q,
        sort: @sort
      )
      @projects_total = Website::Catalog.projects.size
      @projects_filtered_count = items.size
      @projects = items.paginate(page: params[:page], per_page: PER_PAGE)
      @page_title = 'Our work — Health Data Insight'
    end

    def show
      @project = Website::Catalog.project(params[:slug])
      raise ActionController::RoutingError, 'Not Found' unless @project

      @service = Website::Catalog.service(@project['primary_service'])
      @related = Website::Catalog.related_projects(@project)
      @participants = Website::Catalog.people_for_slugs(@project['participants'])
      @page_title = "#{@project['name']} — Health Data Insight"
    end

    private

    def normalize_list_param(value)
      Array(value).map(&:to_s).reject(&:blank?).uniq
    end

    def apply_legacy_keyword_param!(keyword)
      slug = keyword.to_s.strip.presence
      return if slug.blank?

      tag = Website::Catalog.keyword(slug)
      facet = tag&.fetch('facet', nil).to_s
      case facet
      when 'service'
        @services_filter = (@services_filter + [slug]).uniq
      when 'method'
        @methods = (@methods + [slug]).uniq
      else
        @subjects = (@subjects + [slug]).uniq
      end
    end
  end
end
