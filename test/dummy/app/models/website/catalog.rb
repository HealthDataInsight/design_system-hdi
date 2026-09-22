# frozen_string_literal: true

# YAML-backed content for the dummy public website.
module Website
  class Catalog
    DATA_PATH = Rails.root.join('config/data')

    class << self
      def services
        load_yaml('services')
      end

      def service(slug)
        find(services, slug)
      end

      def projects
        load_yaml('projects')
      end

      def project(slug)
        find(projects, slug)
      end

      def featured_projects
        projects.select { |project| project['featured'] }
      end

      def projects_for_service(slug)
        projects.select do |project|
          project['primary_service'] == slug || Array(project['secondary_services']).include?(slug)
        end
      end

      def projects_for_keyword(keyword)
        projects.select do |project|
          Array(project['keywords']).any? { |tag| tag['slug'] == keyword }
        end
      end

      # Unique tags across projects, keyed by slug (first label/facet wins).
      def keywords
        projects.each_with_object({}) do |project, by_slug|
          Array(project['keywords']).each do |tag|
            by_slug[tag['slug']] ||= tag
          end
        end.values
      end

      def keyword(slug)
        keywords.find { |tag| tag['slug'] == slug }
      end

      def news
        load_yaml('news')
      end

      def publications
        load_yaml('publications')
      end

      def people
        load_yaml('people') || {}
      end

      def partners
        load_yaml('partners') || {}
      end

      # Service pages: one unlabeled logo row, no featured NHS/NDRS chrome.
      # Only logos that explicitly list the service slug are included.
      def partners_for_service(slug)
        source = partners
        return source if slug.blank?

        logos = Array(source['featured']).concat(Array(source['rows']).flat_map { |row| row['logos'] })
        matched = filter_partner_logos(logos, slug)

        {
          'featured' => [],
          'rows' => matched.empty? ? [] : [{ 'logos' => matched }]
        }
      end

      def stats
        load_yaml('stats')
      end

      def related_projects(project)
        Array(project['related']).filter_map { |slug| self.project(slug) }
      end

      # Resolve project partner_logos entries (names or inline hashes) against
      # partners.yml so project pages can reuse the same logo assets.
      def partner_logos_for(project)
        entries = Array(project && project['partner_logos'])
        return [] if entries.empty?

        index = partner_logo_index
        entries.filter_map do |entry|
          if entry.is_a?(Hash)
            entry
          else
            index[entry.to_s]
          end
        end
      end

      private

      def load_yaml(name)
        YAML.safe_load_file(DATA_PATH.join("#{name}.yml"), permitted_classes: [Date], aliases: true) || []
      end

      def find(collection, slug)
        collection.find { |item| item['slug'] == slug }
      end

      def filter_partner_logos(logos, slug)
        Array(logos).select { |logo| Array(logo['services']).include?(slug) }
      end

      def partner_logo_index
        logos = Array(partners['featured']).concat(
          Array(partners['rows']).flat_map { |row| Array(row['logos']) }
        )
        logos.each_with_object({}) do |logo, by_name|
          name = logo['name']
          by_name[name] ||= logo if name.present?
        end
      end
    end
  end
end
