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

    def about; end

    def trust; end

    def contact
      @enquiry = Website::Enquiry.new
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
      params.require(:website_enquiry).permit(:topic, :name, :organisation, :message)
    end
  end
end
