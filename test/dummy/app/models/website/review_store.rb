# frozen_string_literal: true

module Website
  # Shared review notes for the dummy site. One JSON file so everyone hitting
  # this server (including via the tunnel) sees the same comments.
  class ReviewStore
    # On disk under the dummy app, not the tunnel and not tmp (which gets cleared).
    DIR = Rails.root.join('storage/website_reviews')
    PATH = DIR.join('comments.json')
    LEGACY_PATH = Rails.root.join('tmp/website_reviews.json')
    LOCK = Mutex.new

    def self.for_path(path)
      LOCK.synchronize { read.select { |item| item['path'] == path } }
    end

    def self.add(attrs)
      item = sanitize(attrs)
      return nil unless item

      LOCK.synchronize do
        items = read
        items << item
        write(items)
      end
      item
    end

    def self.reply(id, attrs)
      body = attrs.to_h.stringify_keys['body'].to_s.strip
      author = attrs.to_h.stringify_keys['author'].to_s.strip
      return nil if body.empty? || body.length > 2_000
      return nil if author.empty? || author.length > 40

      LOCK.synchronize do
        items = read
        item = items.find { |entry| entry['id'] == id }
        return nil unless item

        item['replies'] ||= []
        item['replies'] << {
          'id' => SecureRandom.uuid,
          'author' => author,
          'body' => body,
          'created_at' => Time.now.utc.iso8601
        }
        write(items)
        item
      end
    end

    def self.move(id, x_value, y_value)
      x = coordinate(x_value)
      y = coordinate(y_value)
      return nil unless x && y

      LOCK.synchronize do
        items = read
        item = items.find { |entry| entry['id'] == id }
        return nil unless item

        item['x'] = x
        item['y'] = y
        write(items)
        item
      end
    end

    def self.remove(id, author)
      author = author.to_s.strip
      return false if author.empty?

      LOCK.synchronize do
        items = read
        item = items.find { |entry| entry['id'] == id }
        return false unless item && item['author'] == author

        write(items.reject { |entry| entry['id'] == id })
        file = image_file(id)
        file.delete if file&.exist?
        true
      end
    end

    def self.remove_reply(id, reply_id, author)
      author = author.to_s.strip
      return nil if author.empty?

      LOCK.synchronize do
        items = read
        item = items.find { |entry| entry['id'] == id }
        return nil unless item

        replies = item['replies'] || []
        return nil unless replies.any? { |entry| entry['id'] == reply_id && entry['author'] == author }

        item['replies'] = replies.reject { |entry| entry['id'] == reply_id }
        write(items)
        item
      end
    end

    def self.image_path(id)
      file = image_file(id)
      file if file&.exist?
    end

    def self.sanitize(attrs)
      attrs = attrs.to_h.stringify_keys
      path = attrs['path'].to_s
      kind = attrs['kind'].to_s
      body = attrs['body'].to_s.strip
      author = attrs['author'].to_s.strip
      return nil unless path.start_with?('/website')
      return nil unless %w[text region].include?(kind)
      return nil if body.empty? || body.length > 2_000
      return nil if author.empty? || author.length > 40

      item = {
        'id' => SecureRandom.uuid,
        'path' => path[0, 300],
        'kind' => kind,
        'body' => body,
        'author' => author,
        'created_at' => Time.now.utc.iso8601,
        'x' => coordinate(attrs['x']) || 0.15,
        'y' => coordinate(attrs['y']) || 0.15,
        'replies' => []
      }

      if kind == 'text'
        quote = attrs['quote'].to_s.strip
        return nil if quote.empty? || quote.length > 500

        item['quote'] = quote
        item['prefix'] = attrs['prefix'].to_s[0, 40]
      else
        region = region_for(attrs['region'])
        return nil unless region

        item['region'] = region
      end

      item['image'] = true if save_image(item['id'], attrs['image'])
      item
    end

    def self.coordinate(value)
      number = Float(value)
      return nil if number.nan? || number.infinite? || number.negative? || number > 1.5

      number.round(4)
    rescue ArgumentError, TypeError
      nil
    end

    def self.save_image(id, data_url)
      match = data_url.to_s.match(%r{\Adata:image/jpeg;base64,([A-Za-z0-9+/=\s]+)\z})
      return false unless match

      bytes = Base64.decode64(match[1])
      return false if bytes.bytesize < 32 || bytes.bytesize > 2_000_000

      DIR.mkpath
      image_file(id).binwrite(bytes)
      true
    rescue ArgumentError
      false
    end

    def self.image_file(id)
      return nil unless id.to_s.match?(/\A[0-9a-f-]{36}\z/i)

      DIR.join("#{id}.jpg")
    end

    def self.region_for(raw)
      raw = raw.to_h.stringify_keys
      stroke = stroke_for(raw['stroke'])
      if stroke
        xs = stroke.map(&:first)
        ys = stroke.map(&:last)
        return {
          'stroke' => stroke.map { |x, y| "#{x},#{y}" }.join(' '),
          'x' => xs.min.round(4),
          'y' => ys.min.round(4),
          'w' => (xs.max - xs.min).round(4),
          'h' => (ys.max - ys.min).round(4)
        }
      end

      values = %w[x y w h].map { |key| Float(raw[key]) }
      return nil if values.any? { |value| value.nan? || value.infinite? }
      return nil if values.any? { |value| value < -0.05 || value > 1.2 }
      return nil if values[2] < 0.005 || values[3] < 0.002

      %w[x y w h].zip(values).to_h { |key, value| [key, value.round(4)] }
    rescue ArgumentError, TypeError
      nil
    end

    def self.stroke_for(raw)
      parts = raw.to_s.split
      return nil if parts.length < 2 || parts.length > 800

      parts.map do |part|
        x_text, y_text = part.split(',', 2)
        x = Float(x_text)
        y = Float(y_text)
        return nil if x.nan? || y.nan? || x < -0.05 || x > 1.2 || y < -0.05 || y > 1.2

        [x.round(4), y.round(4)]
      end
    rescue ArgumentError, TypeError
      nil
    end

    def self.read
      migrate_legacy
      return [] unless PATH.exist?

      JSON.parse(PATH.read)
    rescue JSON::ParserError
      []
    end

    def self.migrate_legacy
      return if PATH.exist? || !LEGACY_PATH.exist?

      DIR.mkpath
      FileUtils.mv(LEGACY_PATH, PATH)
    end

    def self.write(items)
      PATH.dirname.mkpath
      PATH.write(JSON.generate(items))
    end

    private_class_method :sanitize, :coordinate, :region_for, :stroke_for, :save_image, :image_file,
                          :read, :write, :migrate_legacy
  end
end
