# frozen_string_literal: true

require "rails/generators"

module Opengraphplus
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      argument :public_key, type: :string, required: false, desc: "Your OpenGraph+ public key"

      desc "Creates an OpenGraphPlus initializer file and adds default Open Graph tags to ApplicationController"

      def copy_initializer
        template "initializer.rb", "config/initializers/opengraphplus.rb"
      end

      def inject_into_application_controller
        inject_into_class "app/controllers/application_controller.rb", "ApplicationController", <<-RUBY

  open_graph do |og|
    og.site_name = "My Website"

    # Render OpenGraph+ images at a mobile viewport width.
    og.plus.viewport.width = 800

    if Rails.env.production?
      # Most Rails sites don't use cache headers, so we set a default
      # max_age in the meta tags to avoid excessive preview image rendering.
      #
      # If you do manage HTTP cache headers in your Rails application, you
      # can delete this tag and/or set this in controllers that don't have
      # caching set.
      og.plus.cache.max_age = 10.minutes
    end

    # Wire up dynamic titles from your models:
    # og.title = @product.title
  end
        RUBY
      end

      def inject_into_layout
        layout_path = "app/views/layouts/application.html.erb"
        return unless File.exist?(layout_path)

        inject_into_file layout_path, "    <%= open_graph_meta_tags %>\n", after: /^\s*<head>\n/
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
