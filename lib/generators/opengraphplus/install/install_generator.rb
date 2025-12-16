# frozen_string_literal: true

require "rails/generators"

module Opengraphplus
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates an OpenGraphPlus initializer file"

      def copy_initializer
        template "initializer.rb", "config/initializers/opengraphplus.rb"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
