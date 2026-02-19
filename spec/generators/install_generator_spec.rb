# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"
require "generators/opengraphplus/install/install_generator"

RSpec.describe Opengraphplus::Generators::InstallGenerator do
  let(:tmpdir) { Dir.mktmpdir }

  before do
    @original_dir = Dir.pwd
    Dir.chdir(tmpdir)
    FileUtils.mkdir_p("app/controllers")
    FileUtils.mkdir_p("app/views/layouts")
    FileUtils.mkdir_p("config/initializers")
  end

  after do
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(tmpdir)
  end

  describe "happy path" do
    let(:public_key) { "pk_test_abc123" }

    before do
      File.write("app/controllers/application_controller.rb", <<~RUBY)
        class ApplicationController < ActionController::Base
          allow_browser versions: :modern
        end
      RUBY
      File.write("app/views/layouts/application.html.erb", <<~ERB)
        <!DOCTYPE html>
        <html>
          <head>
            <title>My App</title>
            <%= csp_meta_tag %>
            <%= stylesheet_link_tag "application" %>
          </head>
          <body>
            <%= yield %>
          </body>
        </html>
      ERB

      described_class.start([public_key], destination_root: tmpdir)
    end

    it "creates the initializer with the public key" do
      initializer = File.read("config/initializers/opengraphplus.rb")
      expect(initializer).to include(%(config.public_key = "#{public_key}"))
    end

    it "injects the open_graph block into ApplicationController" do
      controller = File.read("app/controllers/application_controller.rb")
      expect(controller).to include("open_graph do |og|")
      expect(controller).to include("og.site_name")
      expect(controller).to include("og.plus.viewport.width = 800")
      expect(controller).to include("og.plus.cache.max_age = 10.minutes")
    end

    it "injects open_graph_meta_tags into the layout" do
      layout = File.read("app/views/layouts/application.html.erb")
      expect(layout).to include("<%= open_graph_meta_tags %>")
    end

    it "comments out allow_browser" do
      controller = File.read("app/controllers/application_controller.rb")
      expect(controller).to include("# allow_browser versions: :modern")
      expect(controller).not_to match(/^\s*allow_browser/)
    end
  end

  describe "#inject_into_layout" do
    it "injects open_graph_meta_tags into the layout head" do
      File.write("app/controllers/application_controller.rb", <<~RUBY)
        class ApplicationController < ActionController::Base
        end
      RUBY
      File.write("app/views/layouts/application.html.erb", <<~ERB)
        <!DOCTYPE html>
        <html>
          <head>
            <title>My App</title>
          </head>
          <body>
            <%= yield %>
          </body>
        </html>
      ERB

      described_class.start([], destination_root: tmpdir)

      content = File.read("app/views/layouts/application.html.erb")
      expect(content).to include("<%= open_graph_meta_tags %>")
    end

    it "skips gracefully when layout does not exist" do
      File.write("app/controllers/application_controller.rb", <<~RUBY)
        class ApplicationController < ActionController::Base
        end
      RUBY

      expect { described_class.start([], destination_root: tmpdir) }.not_to raise_error
    end
  end

  describe "#inject_into_application_controller" do
    it "includes viewport width setting" do
      File.write("app/controllers/application_controller.rb", <<~RUBY)
        class ApplicationController < ActionController::Base
        end
      RUBY

      described_class.start([], destination_root: tmpdir)

      content = File.read("app/controllers/application_controller.rb")
      expect(content).to include("og.plus.viewport.width = 800")
    end

    it "includes commented-out title example" do
      File.write("app/controllers/application_controller.rb", <<~RUBY)
        class ApplicationController < ActionController::Base
        end
      RUBY

      described_class.start([], destination_root: tmpdir)

      content = File.read("app/controllers/application_controller.rb")
      expect(content).to include("# og.title = @product.title")
    end
  end

  describe "#comment_out_allow_browser" do
    it "comments out allow_browser line when present" do
      File.write("app/controllers/application_controller.rb", <<~RUBY)
        class ApplicationController < ActionController::Base
          allow_browser versions: :modern
        end
      RUBY

      described_class.start([], destination_root: tmpdir)

      content = File.read("app/controllers/application_controller.rb")
      expect(content).to include("# This blocks OpenGraph requests from consumers like Apple, LinkedIn, etc.")
      expect(content).to include("# allow_browser versions: :modern")
      expect(content).not_to match(/^\s*allow_browser versions: :modern$/)
    end

    it "preserves indentation when commenting out" do
      File.write("app/controllers/application_controller.rb", <<~RUBY)
        class ApplicationController < ActionController::Base
          allow_browser versions: :modern
        end
      RUBY

      described_class.start([], destination_root: tmpdir)

      content = File.read("app/controllers/application_controller.rb")
      expect(content).to include("  # This blocks OpenGraph requests")
      expect(content).to include("  # allow_browser")
    end

    it "does nothing when allow_browser is not present" do
      original = <<~RUBY
        class ApplicationController < ActionController::Base
        end
      RUBY
      File.write("app/controllers/application_controller.rb", original)

      described_class.start([], destination_root: tmpdir)

      content = File.read("app/controllers/application_controller.rb")
      expect(content).not_to include("# This blocks OpenGraph")
    end

    it "handles allow_browser with different options" do
      File.write("app/controllers/application_controller.rb", <<~RUBY)
        class ApplicationController < ActionController::Base
          allow_browser versions: { safari: 15, chrome: 100 }
        end
      RUBY

      described_class.start([], destination_root: tmpdir)

      content = File.read("app/controllers/application_controller.rb")
      expect(content).to include("# allow_browser versions: { safari: 15, chrome: 100 }")
    end
  end
end
