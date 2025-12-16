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
    og.type = "website"
    og.url = request.original_url
    og.site_name = Rails.application.class.module_parent_name.titleize
  end
        RUBY
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
