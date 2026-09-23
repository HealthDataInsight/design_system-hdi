# frozen_string_literal: true

module Website
  class PagesController < BaseController
    ACKNOWLEDGEMENT = 'Thank you. We will reply within 3 working days.'
    def home
      @stats = Website::Catalog.stats
      @services = Website::Catalog.services
      @featured_projects = Website::Catalog.featured_projects
      @news = Website::Catalog.news
      @partners = Website::Catalog.partners
    end

    def about
      @page_title = 'About — Health Data Insight'
    end

    def people
      @people = Website::Catalog.people
      @page_title = 'People — Health Data Insight'
    end

    def person
      @person = Website::Catalog.person(params[:slug])
      raise ActionController::RoutingError, 'Not Found' unless @person

      @projects = Website::Catalog.projects_for_person(@person['slug'])
      @page_title = "#{@person['name']} — Health Data Insight"
    end

    def internships
      @page_title = 'Internships — Health Data Insight'
    end

    def trust; end

    def news
      @news = Website::Catalog.news
      @page_title = 'News — Health Data Insight'
    end

    def publications
      @q = params[:q].to_s.strip.presence
      @year = params[:year].to_s.strip.presence
      @types = Array(params[:type].presence || params[:types]).map(&:to_s).reject(&:blank?)
      @subjects = Array(params[:subject].presence || params[:subjects]).map(&:to_s).reject(&:blank?)
      @with_ndrs = ActiveModel::Type::Boolean.new.cast(params[:with_ndrs])
      @open_access = ActiveModel::Type::Boolean.new.cast(params[:open_access])
      @sort = params[:sort].to_s.strip.presence || 'newest'

      @publication_stats = Website::Catalog.publication_stats
      @publication_year_toggles = Website::Catalog.publication_year_toggles
      @type_counts = Website::Catalog.publication_type_counts
      @subject_counts = Website::Catalog.publication_subject_counts
      @partner_counts = Website::Catalog.publication_partner_counts

      items = Website::Catalog.publication_items(
        year: @year,
        q: @q,
        types: @types,
        subjects: @subjects,
        with_ndrs: @with_ndrs,
        open_access: @open_access,
        sort: @sort
      )
      @publications_total = Website::Catalog.all_publication_items.size
      @publications_filtered_count = items.size
      @publications = items.paginate(page: params[:page], per_page: 10)
      @page_title = 'Publications — Health Data Insight'
    end

    def privacy
      @page_title = 'Privacy — Health Data Insight'
    end

    def contact
      @enquiry = Website::Enquiry.new(topic: params[:topic].presence)
    end

    def submit_contact
      @enquiry = Website::Enquiry.new(enquiry_params)
      if @enquiry.valid?
        redirect_to website_contact_path, notice: ACKNOWLEDGEMENT
      else
        render :contact, status: :unprocessable_entity
      end
    end

    private

    def enquiry_params
      params.require(:website_enquiry).permit(
        :topic, :name, :email, :organisation, :timescale, :message, :privacy
      )
    end
  end
end
