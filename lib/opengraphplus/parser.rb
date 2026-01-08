# frozen_string_literal: true

require "nokogiri"

module OpenGraphPlus
  class Parser
    REQUIRED_TAGS = %w[og:title og:type og:image og:url].freeze
    RECOMMENDED_TAGS = %w[og:description og:site_name twitter:card twitter:title twitter:image].freeze

    attr_reader :html

    def initialize(html)
      @html = html.to_s
      @tags = parse_meta_tags
    end

    def og_tags
      @tags.select { |key, _| key.start_with?("og:") }
    end

    def twitter_tags
      @tags.select { |key, _| key.start_with?("twitter:") }
    end

    def all_tags
      @tags.dup
    end

    def [](property)
      @tags[property]
    end

    def valid?
      errors.empty?
    end

    def errors
      REQUIRED_TAGS.reject { |tag| @tags.key?(tag) }
    end

    def warnings
      RECOMMENDED_TAGS.reject { |tag| @tags.key?(tag) }
    end

    private

    def parse_meta_tags
      doc = Nokogiri::HTML(@html)
      tags = {}

      doc.css("meta[property^='og:'], meta[name^='og:']").each do |meta|
        property = meta["property"] || meta["name"]
        content = meta["content"]
        tags[property] = content if property && content
      end

      doc.css("meta[property^='twitter:'], meta[name^='twitter:']").each do |meta|
        property = meta["property"] || meta["name"]
        content = meta["content"]
        tags[property] = content if property && content
      end

      tags
    end
  end
end
