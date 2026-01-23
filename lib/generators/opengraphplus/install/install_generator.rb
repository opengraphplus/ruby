# frozen_string_literal: true

require "rails/generators"

module Opengraphplus
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates an OpenGraphPlus initializer file and adds default Open Graph tags to ApplicationController"

      def copy_initializer
        template "initializer.rb", "config/initializers/opengraphplus.rb"
      end

      def inject_into_application_controller
        inject_into_class "app/controllers/application_controller.rb", "ApplicationController", <<-RUBY

  open_graph do |og|
    # Change to the name of your website. Required for Open Graph
    # consumers like Twitter.
    og.site_name = "My Website"

    if Rails.env.production?
      # Most Rails sites don't use cache headers, so we set a default
      # max_age in the meta tags to avoid excessive preview image rendering.
      #
      # If you do manage HTTP cache headers in your Rails application, you
      # can delete this tag and/or set this in controllers that don't have
      # caching set.
      og.plus.cache.max_age = 10.minutes
    end
  end
        RUBY
      end

      def comment_out_allow_browser
        application_controller = "app/controllers/application_controller.rb"
        return unless File.exist?(application_controller)

        content = File.read(application_controller)
        return unless content =~ /^\s*allow_browser\b/

        gsub_file application_controller, /^(\s*)(allow_browser.*)$/, "\\1# This blocks OpenGraph requests from consumers like Apple, LinkedIn, etc.\n\\1# \\2"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
