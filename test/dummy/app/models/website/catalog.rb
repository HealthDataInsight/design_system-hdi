# frozen_string_literal: true

# YAML-backed content for the dummy public website.
module Website
  class Catalog
    DATA_PATH = Rails.root.join('config/data')

    PUBLICATION_TYPES = [
      'Journal article',
      'National report',
      'Methods paper',
      'Preprint'
    ].freeze

    PUBLICATION_SUBJECTS = [
      'Cancer',
      'Synthetic data',
      'Genomics',
      'Screening & early diagnosis',
      'Health inequalities'
    ].freeze

    # Years shown as individual toggles; older years collapse into "Earlier".
    PUBLICATION_YEAR_TOGGLE_FROM = 2022

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

      def keywords_for_facet(facet)
        keywords.select { |tag| tag['facet'].to_s == facet.to_s }
                .sort_by { |tag| tag['label'].to_s.downcase }
      end

      # Filtered/sorted project rows for the Our work index.
      def project_items(services: [], subjects: [], methods: [], statuses: [],
                        q: nil, sort: nil)
        items = projects.map { |project| normalize_project_item(project) }
        items = filter_project_services(items, services)
        items = filter_project_keyword_facet(items, subjects, 'subject')
        items = filter_project_keyword_facet(items, methods, 'method')
        items = filter_project_statuses(items, statuses)
        items = filter_project_query(items, q)
        sort_project_items(items, sort)
      end

      def project_stats
        items = projects
        partners = items.filter_map { |p| p['partner_short'].presence || p['partner'].presence }.uniq
        {
          total: items.size,
          live: items.count { |p| project_status_bucket(p['status']) == 'Live' },
          partners: partners.size
        }
      end

      def project_service_counts
        counts = Hash.new(0)
        projects.each do |project|
          slug = project['primary_service']
          counts[slug] += 1 if slug.present?
        end
        counts
      end

      def project_subject_counts
        keyword_facet_counts('subject')
      end

      def project_method_counts
        keyword_facet_counts('method')
      end

      def project_status_counts
        counts = Hash.new(0)
        projects.each do |project|
          bucket = project_status_bucket(project['status'])
          counts[bucket] += 1 if bucket
        end
        counts
      end

      # Map free-text status to Live / Completed buckets for filters.
      def project_status_bucket(status)
        text = status.to_s.downcase
        return nil if text.blank?
        return 'Completed' if text.include?('complete')
        return 'Live' if text.include?('live') || text.include?('in use')

        nil
      end

      def news
        load_yaml('news')
      end

      def publications
        load_yaml('publications')
      end

      # Flattened publication rows with year attached.
      def publication_items(year: nil, q: nil, types: [], subjects: [],
                            with_ndrs: nil, open_access: nil, sort: nil)
        items = all_publication_items
        items = filter_publication_year(items, year)
        items = filter_publication_types(items, types)
        items = filter_publication_subjects(items, subjects)
        items = filter_publication_flag(items, 'with_ndrs', with_ndrs)
        items = filter_publication_flag(items, 'open_access', open_access)
        items = filter_publication_query(items, q)
        sort_publication_items(items, sort)
      end

      def all_publication_items
        publications.flat_map do |group|
          group_year = group['year'].to_s
          Array(group['items']).map { |item| normalize_publication_item(item, group_year) }
        end
      end

      def publication_years
        publications.filter_map { |group| group['year']&.to_s }.uniq
      end

      # Recent years (desc) for the year toggle grid, plus whether "Earlier" is needed.
      def publication_year_toggles
        years = publication_years.map(&:to_i).uniq.sort.reverse
        recent = years.select { |y| y >= PUBLICATION_YEAR_TOGGLE_FROM }.map(&:to_s)
        earlier = years.any? { |y| y < PUBLICATION_YEAR_TOGGLE_FROM }
        { years: recent, earlier: earlier }
      end

      def publication_stats
        items = all_publication_items
        years = items.filter_map { |item| item['year'].to_i if item['year'].present? }
        {
          total: items.size,
          with_ndrs: items.count { |item| item['with_ndrs'] },
          earliest: years.min || 2012
        }
      end

      def publication_type_counts
        counts = Hash.new(0)
        all_publication_items.each { |item| counts[item['type']] += 1 if item['type'].present? }
        counts
      end

      def publication_subject_counts
        counts = Hash.new(0)
        all_publication_items.each do |item|
          Array(item['subjects']).each { |subject| counts[subject] += 1 }
        end
        counts
      end

      def publication_partner_counts
        items = all_publication_items
        {
          with_ndrs: items.count { |item| item['with_ndrs'] },
          open_access: items.count { |item| item['open_access'] }
        }
      end

      def people
        load_yaml('people') || {}
      end

      # Flat list of every person (directors, team, associates) with slug + group.
      def all_people
        source = people
        %w[directors team associates].flat_map do |group|
          Array(source[group]).map { |row| normalize_person(row, group) }
        end
      end

      def person(slug)
        all_people.find { |row| row['slug'] == slug.to_s }
      end

      def people_for_slugs(slugs)
        Array(slugs).filter_map { |slug| person(slug) }
      end

      def projects_for_person(slug)
        projects.select { |project| Array(project['participants']).include?(slug.to_s) }
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

      def normalize_person(person, group)
        row = person.is_a?(Hash) ? person.dup : {}
        row['slug'] = row['slug'].presence || row['name'].to_s.parameterize
        row['group'] = group
        row
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

      # Map legacy `kind: "Journal article · BMJ"` rows into type + journal.
      def normalize_publication_item(item, year)
        row = item.merge('year' => year)
        return row if row['type'].present?

        kind = row['kind'].to_s
        if kind.include?(' · ')
          type, journal = kind.split(' · ', 2)
          row['type'] = type
          row['journal'] ||= journal
        else
          row['type'] = case kind
                        when 'Technical report' then 'Methods paper'
                        when 'Collection' then 'National report'
                        else kind.presence || 'Journal article'
                        end
        end
        row
      end

      def filter_publication_year(items, year)
        return items if year.blank?

        if year.to_s.downcase == 'earlier'
          items.select { |item| item['year'].to_i < PUBLICATION_YEAR_TOGGLE_FROM }
        else
          items.select { |item| item['year'] == year.to_s }
        end
      end

      def filter_publication_types(items, types)
        selected = Array(types).map(&:to_s).reject(&:blank?)
        return items if selected.empty?

        items.select { |item| selected.include?(item['type']) }
      end

      def filter_publication_subjects(items, subjects)
        selected = Array(subjects).map(&:to_s).reject(&:blank?)
        return items if selected.empty?

        items.select { |item| (Array(item['subjects']) & selected).any? }
      end

      def filter_publication_flag(items, key, value)
        return items unless truthy_param?(value)

        items.select { |item| item[key] }
      end

      def filter_publication_query(items, q)
        return items if q.blank?

        needle = q.to_s.downcase
        items.select do |item|
          [item['title'], item['authors'], item['journal'], item['type'], Array(item['subjects']).join(' ')]
            .compact.join(' ').downcase.include?(needle)
        end
      end

      def sort_publication_items(items, sort)
        case sort.to_s
        when 'oldest'
          items.sort_by { |item| [item['year'].to_i, item['title'].to_s.downcase] }
        when 'title'
          items.sort_by { |item| item['title'].to_s.downcase }
        else # newest
          items.sort_by { |item| [-item['year'].to_i, item['title'].to_s.downcase] }
        end
      end

      def truthy_param?(value)
        ActiveModel::Type::Boolean.new.cast(value)
      end

      def normalize_project_item(project)
        project.merge(
          'status_bucket' => project_status_bucket(project['status'])
        )
      end

      def filter_project_services(items, services)
        selected = Array(services).map(&:to_s).reject(&:blank?)
        return items if selected.empty?

        items.select do |project|
          selected.include?(project['primary_service']) ||
            (Array(project['secondary_services']) & selected).any?
        end
      end

      def filter_project_keyword_facet(items, slugs, facet)
        selected = Array(slugs).map(&:to_s).reject(&:blank?)
        return items if selected.empty?

        items.select do |project|
          Array(project['keywords']).any? do |tag|
            tag['facet'].to_s == facet.to_s && selected.include?(tag['slug'])
          end
        end
      end

      def filter_project_statuses(items, statuses)
        selected = Array(statuses).map(&:to_s).reject(&:blank?)
        return items if selected.empty?

        items.select { |project| selected.include?(project['status_bucket']) }
      end

      def filter_project_query(items, q)
        return items if q.blank?

        needle = q.to_s.downcase
        items.select do |project|
          keywords = Array(project['keywords']).map { |tag| tag['label'] }.join(' ')
          [
            project['title'], project['name'], project['partner'],
            project['partner_short'], project['summary'], keywords
          ].compact.join(' ').downcase.include?(needle)
        end
      end

      def sort_project_items(items, sort)
        case sort.to_s
        when 'title'
          items.sort_by { |project| project['title'].to_s.downcase }
        else # newest — featured first, then by name (YAML order as proxy)
          items.each_with_index.sort_by do |project, index|
            [project['featured'] ? 0 : 1, index]
          end.map(&:first)
        end
      end

      def keyword_facet_counts(facet)
        counts = Hash.new(0)
        projects.each do |project|
          Array(project['keywords']).each do |tag|
            next unless tag['facet'].to_s == facet.to_s

            counts[tag['slug']] += 1
          end
        end
        counts
      end
    end
  end
end
