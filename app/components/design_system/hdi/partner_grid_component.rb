# frozen_string_literal: true

module DesignSystem
  module Hdi
    # Partner section: optional featured marks, then unlabeled logo
    # carousels constrained to `.hdi-section__inner`. `groups` is typically
    # scoped by the caller. Service pages pass `tags` and omit featured/intro.
    class PartnerGridComponent < DesignSystem::BaseComponent
      def initialize(heading: nil, intro: nil, tags: [], featured: [], groups: [])
        super()
        @heading = heading
        @intro = intro
        @tags = Array(tags)
        @featured = Array(featured)
        @groups = Array(groups)
      end

      attr_reader :heading, :intro, :tags, :featured, :groups
    end
  end
end
